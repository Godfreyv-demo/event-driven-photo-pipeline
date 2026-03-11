resource "aws_lambda_function" "image_processor" {
  function_name = "${local.name_prefix}-image-processor"
  role          = aws_iam_role.image_processor.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"

  filename         = "${path.module}/../../dist/image_processor.zip"
  source_code_hash = filebase64sha256("${path.module}/../../dist/image_processor.zip")

  timeout     = 30
  memory_size = 512

  layers = [aws_lambda_layer_version.pillow.arn]

  environment {
    variables = {
      RAW_BUCKET       = aws_s3_bucket.raw.bucket
      PROCESSED_BUCKET = aws_s3_bucket.processed.bucket
      DDB_TABLE        = aws_dynamodb_table.photo_metadata.name
      THUMB_MAX_EDGE   = "512"
      OUTPUT_PREFIX    = "thumbnails/"
    }
  }
}