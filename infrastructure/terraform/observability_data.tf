locals {
  lambda_log_group_name = "/aws/lambda/${var.lambda_function_name}"

  metric_namespace = "PhotoPipeline/Processing"

  common_tags = {
    Project     = "event-driven-photo-pipeline"
    Environment = "dev"
    ManagedBy   = "terraform"
    Component   = "observability"
  }
}