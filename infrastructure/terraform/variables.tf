variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used for naming/tagging"
  type        = string
  default     = "event-driven-photo-pipeline"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "queue_message_retention_seconds" {
  description = "How long messages stay in the main queue if not deleted"
  type        = number
  default     = 345600
}

variable "dlq_message_retention_seconds" {
  description = "How long failed messages stay in the DLQ"
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  description = "How many times a message can be received before going to DLQ"
  type        = number
  default     = 5
}

variable "visibility_timeout_seconds" {
  description = "How long a message is hidden after a consumer receives it"
  type        = number
  default     = 60
}