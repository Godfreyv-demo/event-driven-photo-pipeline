data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "image_processor" {
  name = "${local.name_prefix}-image-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "image_processor" {
  name = "${local.name_prefix}-image-processor-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-image-processor:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-image-processor:*:*"
        ]
      },
      {
        Sid    = "AllowConsumeMainQueue",
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = [
          aws_sqs_queue.main.arn
        ]
      },
      {
        Sid    = "AllowReadRawBucket",
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.raw.arn}/*"
        ]
      },
      {
        Sid    = "AllowWriteProcessedBucket",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        Resource = [
          "${aws_s3_bucket.processed.arn}/*"
        ]
      },
      {
        Sid    = "AllowDynamoDBMetadataWrites",
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = [
          aws_dynamodb_table.photo_metadata.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "image_processor" {
  role       = aws_iam_role.image_processor.name
  policy_arn = aws_iam_policy.image_processor.arn
}