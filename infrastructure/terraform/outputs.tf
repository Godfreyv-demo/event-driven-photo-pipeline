output "sqs_main_queue_url" {
  value       = aws_sqs_queue.main.url
  description = "URL of the main SQS queue"
}

output "sqs_main_queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "ARN of the main SQS queue"
}

output "sqs_dlq_url" {
  value       = aws_sqs_queue.dlq.url
  description = "URL of the DLQ"
}

output "sqs_dlq_arn" {
  value       = aws_sqs_queue.dlq.arn
  description = "ARN of the DLQ"
}

output "s3_raw_bucket_name" {
  value       = aws_s3_bucket.raw.bucket
  description = "Raw uploads bucket name"
}

output "s3_processed_bucket_name" {
  value       = aws_s3_bucket.processed.bucket
  description = "Processed bucket name"
}

output "eventbridge_rule_arn" {
  value       = aws_cloudwatch_event_rule.s3_object_created.arn
  description = "EventBridge rule ARN for S3 Object Created events"
}