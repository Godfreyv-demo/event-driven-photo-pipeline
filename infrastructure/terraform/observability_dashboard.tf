resource "aws_cloudwatch_dashboard" "pipeline_dashboard" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        "type"   = "text",
        "x"      = 0,
        "y"      = 0,
        "width"  = 24,
        "height" = 2,
        "properties" = {
          "markdown" = "# Event Driven Photo Processing Pipeline\nOperational visibility for Lambda, SQS, DLQ, and application processing outcomes."
        }
      },
      {
        "type"   = "metric",
        "x"      = 0,
        "y"      = 2,
        "width"  = 12,
        "height" = 6,
        "properties" = {
          "title"   = "Lambda Health",
          "region"  = var.aws_region,
          "view"    = "timeSeries",
          "stacked" = false,
          "metrics" = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name],
            [".", "Throttles", ".", "."],
            [".", "Invocations", ".", "."]
          ]
        }
      },
      {
        "type"   = "metric",
        "x"      = 12,
        "y"      = 2,
        "width"  = 12,
        "height" = 6,
        "properties" = {
          "title"   = "Lambda Performance",
          "region"  = var.aws_region,
          "view"    = "timeSeries",
          "stacked" = false,
          "metrics" = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name, { "stat" = "Average" }],
            ["...", { "stat" = "p95", "label" = "Duration p95" }],
            [".", "ConcurrentExecutions", ".", ".", { "stat" = "Maximum" }]
          ]
        }
      },
      {
        "type"   = "metric",
        "x"      = 0,
        "y"      = 8,
        "width"  = 12,
        "height" = 6,
        "properties" = {
          "title"   = "Main Queue Depth",
          "region"  = var.aws_region,
          "view"    = "timeSeries",
          "stacked" = false,
          "metrics" = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.main_queue_name],
            [".", "ApproximateAgeOfOldestMessage", ".", "."]
          ]
        }
      },
      {
        "type"   = "metric",
        "x"      = 12,
        "y"      = 8,
        "width"  = 12,
        "height" = 6,
        "properties" = {
          "title"   = "DLQ Health",
          "region"  = var.aws_region,
          "view"    = "timeSeries",
          "stacked" = false,
          "metrics" = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_queue_name]
          ]
        }
      },
      {
        "type"   = "metric",
        "x"      = 0,
        "y"      = 14,
        "width"  = 24,
        "height" = 6,
        "properties" = {
          "title"   = "Processing Outcomes",
          "region"  = var.aws_region,
          "view"    = "timeSeries",
          "stacked" = false,
          "metrics" = [
            [local.metric_namespace, "processing_success"],
            [".", "processing_failed"]
          ]
        }
      }
    ]
  })
}