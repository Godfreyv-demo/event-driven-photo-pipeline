variable "lambda_function_name" {
  description = "Name of the image processor Lambda"
  type        = string
  default     = "event-driven-photo-pipeline-dev-image-processor"
}

variable "main_queue_name" {
  description = "Name of the main SQS queue"
  type        = string
  default     = "event-driven-photo-pipeline-dev-photo-events"
}

variable "dlq_queue_name" {
  description = "Name of the dead-letter queue"
  type        = string
  default     = "event-driven-photo-pipeline-dev-photo-events-dlq"
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
  default     = "event-driven-photo-pipeline-dev-observability"
}

variable "alarm_topic_name" {
  description = "SNS topic name for CloudWatch alarms"
  type        = string
  default     = "event-driven-photo-pipeline-dev-alerts"
}

variable "alert_email" {
  description = "Optional email address for SNS alarm notifications. Leave empty to skip email subscription."
  type        = string
  default     = ""
}

variable "lambda_error_threshold" {
  description = "Alarm when Lambda errors in evaluation period are greater than or equal to this value"
  type        = number
  default     = 1
}

variable "lambda_throttle_threshold" {
  description = "Alarm when Lambda throttles in evaluation period are greater than or equal to this value"
  type        = number
  default     = 1
}

variable "lambda_duration_p95_threshold_ms" {
  description = "Alarm when Lambda p95 duration exceeds this value in milliseconds"
  type        = number
  default     = 20000
}

variable "queue_visible_messages_threshold" {
  description = "Alarm when visible messages in main queue exceed this threshold"
  type        = number
  default     = 10
}

variable "queue_oldest_message_age_threshold_seconds" {
  description = "Alarm when age of oldest message exceeds this threshold in seconds"
  type        = number
  default     = 300
}

variable "dlq_visible_messages_threshold" {
  description = "Alarm when DLQ has visible messages greater than or equal to this value"
  type        = number
  default     = 1
}

variable "processing_failed_threshold" {
  description = "Alarm when processing_failed log metric is greater than or equal to this value"
  type        = number
  default     = 1
}