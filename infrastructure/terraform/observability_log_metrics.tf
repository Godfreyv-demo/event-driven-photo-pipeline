resource "aws_cloudwatch_log_metric_filter" "processing_success" {
  name           = "${var.lambda_function_name}-processing-success"
  log_group_name = local.lambda_log_group_name

  # Assumes structured JSON logs contain: {"event":"processing_success"}
  pattern = "{ $.event = \"processing_success\" }"

  metric_transformation {
    name      = "processing_success"
    namespace = local.metric_namespace
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "processing_failed" {
  name           = "${var.lambda_function_name}-processing-failed"
  log_group_name = local.lambda_log_group_name

  # Assumes structured JSON logs contain: {"event":"processing_failed"}
  pattern = "{ $.event = \"processing_failed\" }"

  metric_transformation {
    name      = "processing_failed"
    namespace = local.metric_namespace
    value     = "1"
    unit      = "Count"
  }
}