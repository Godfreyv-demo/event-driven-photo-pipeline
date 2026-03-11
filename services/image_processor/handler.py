import os
import json
import io
import hashlib
import urllib.parse
from datetime import datetime, timezone
from typing import Dict, Tuple

import boto3
from botocore.exceptions import ClientError
from PIL import Image

s3 = boto3.client("s3")
ddb = boto3.client("dynamodb")

RAW_BUCKET = os.environ["RAW_BUCKET"]
PROCESSED_BUCKET = os.environ["PROCESSED_BUCKET"]
DDB_TABLE = os.environ["DDB_TABLE"]

THUMB_MAX_EDGE = int(os.environ.get("THUMB_MAX_EDGE", "512"))
OUTPUT_PREFIX = os.environ.get("OUTPUT_PREFIX", "thumbnails/")


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def log(level: str, msg: str, **fields):
    payload = {
        "ts": now_iso(),
        "level": level,
        "msg": msg,
        **fields,
    }
    print(json.dumps(payload, separators=(",", ":")))


def parse_eventbridge_s3_event(eventbridge_event: Dict) -> Tuple[str, str]:
    detail = eventbridge_event.get("detail") or {}
    bucket = (detail.get("bucket") or {}).get("name")
    obj = detail.get("object") or {}
    key = obj.get("key")

    if not bucket or not key:
        raise ValueError("Missing bucket/key in EventBridge event")

    key = urllib.parse.unquote_plus(key)
    return bucket, key


def deterministic_output_key(raw_key: str) -> str:
    h = hashlib.sha256(raw_key.encode("utf-8")).hexdigest()[:16]
    base = raw_key.rsplit("/", 1)[-1]
    stem = base.rsplit(".", 1)[0]
    return f"{OUTPUT_PREFIX}{h}/{stem}_thumb.jpg"


def validate_and_thumbnail(raw_bytes: bytes) -> Tuple[bytes, int, int, str]:
    with Image.open(io.BytesIO(raw_bytes)) as img:
        img.verify()

    with Image.open(io.BytesIO(raw_bytes)) as img:
        img = img.convert("RGB")
        img.thumbnail((THUMB_MAX_EDGE, THUMB_MAX_EDGE))
        out = io.BytesIO()
        img.save(out, format="JPEG", quality=85, optimize=True)
        b = out.getvalue()
        w, h = img.size
        return b, w, h, "image/jpeg"


def ddb_put_idempotent(pk: str, item: Dict) -> bool:
    try:
        ddb.put_item(
            TableName=DDB_TABLE,
            Item=item,
            ConditionExpression="attribute_not_exists(pk)",
        )
        return True
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return False
        raise


def process_message(record: Dict):
    message_id = record.get("messageId", "unknown")
    body = record.get("body") or ""

    try:
        eventbridge_event = json.loads(body)
    except json.JSONDecodeError:
        raise ValueError("SQS body is not valid JSON (expected EventBridge event)")

    bucket, raw_key = parse_eventbridge_s3_event(eventbridge_event)

    if bucket != RAW_BUCKET:
        raise ValueError(f"Unexpected bucket '{bucket}' (expected '{RAW_BUCKET}')")

    pk = f"s3://{RAW_BUCKET}/{raw_key}"
    out_key = deterministic_output_key(raw_key)

    log("INFO", "processing_start", messageId=message_id, pk=pk, rawKey=raw_key, outKey=out_key)

    obj = s3.get_object(Bucket=RAW_BUCKET, Key=raw_key)
    raw_bytes = obj["Body"].read()
    raw_size = obj.get("ContentLength", len(raw_bytes))
    raw_etag = (obj.get("ETag") or "").strip('"')

    thumb_bytes, w, h, content_type = validate_and_thumbnail(raw_bytes)

    s3.put_object(
        Bucket=PROCESSED_BUCKET,
        Key=out_key,
        Body=thumb_bytes,
        ContentType=content_type,
        Metadata={
            "source_key": raw_key,
            "source_etag": raw_etag,
        },
    )

    item = {
        "pk": {"S": pk},
        "raw_bucket": {"S": RAW_BUCKET},
        "raw_key": {"S": raw_key},
        "raw_etag": {"S": raw_etag},
        "raw_size": {"N": str(raw_size)},
        "processed_bucket": {"S": PROCESSED_BUCKET},
        "processed_key": {"S": out_key},
        "thumb_w": {"N": str(w)},
        "thumb_h": {"N": str(h)},
        "created_at": {"S": now_iso()},
    }

    inserted = ddb_put_idempotent(pk, item)
    if not inserted:
        log("INFO", "duplicate_event", messageId=message_id, pk=pk)

    log("INFO", "processing_success", messageId=message_id, pk=pk, outKey=out_key)


def lambda_handler(event, context):
    records = event.get("Records") or []
    log("INFO", "batch_received", recordCount=len(records))

    failures = []
    for r in records:
        msg_id = r.get("messageId", "unknown")
        try:
            process_message(r)
        except Exception as e:
            log("ERROR", "processing_failed", messageId=msg_id, error=str(e))
            failures.append({"itemIdentifier": msg_id})

    return {"batchItemFailures": failures}