# CI/CD Handover — Event Driven Photo Processing Pipeline

## Project

Production-style event-driven photo processing pipeline built on AWS with Terraform-managed infrastructure.

## Architecture

Upload  
↓  
S3 raw bucket  
↓  
EventBridge  
↓  
SQS queue  
↓  
Lambda image processor  
↓  
S3 processed bucket (thumbnails)  
↓  
DynamoDB metadata table  

## Current AWS Resources

**Region**  
eu-west-1

**Raw bucket**  
event-driven-photo-pipeline-dev-raw-5f870adb

**Processed bucket**  
event-driven-photo-pipeline-dev-processed-5f870adb

**Main queue**  
event-driven-photo-pipeline-dev-photo-events

**DLQ**  
event-driven-photo-pipeline-dev-photo-events-dlq

**Lambda function**  
event-driven-photo-pipeline-dev-image-processor

**Lambda runtime**  
python3.11

**Lambda memory**  
512 MB

**Lambda timeout**  
30 seconds

**Lambda layer**  
event-driven-photo-pipeline-dev-pillow

**DynamoDB table**  
event-driven-photo-pipeline-dev-photo-metadata

## Current Monitoring Implemented

Terraform-based observability was added for production-style operational visibility.

### CloudWatch alarms
- Lambda Errors
- Lambda Throttles
- Lambda p95 Duration
- Main queue visible message backlog
- Main queue oldest message age
- DLQ visible message count
- Application processing_failed log metric alarm

### CloudWatch dashboard
Dashboard created for:
- Lambda health
- Lambda performance
- Main queue depth
- DLQ health
- Processing success/failure trends

### Log metrics created
Custom CloudWatch log metric filters:
- processing_success
- processing_failed

**Namespace used:**  
PhotoPipeline/Processing

## Alerts Configured

SNS topic created for CloudWatch alarm notifications.

**SNS topic name**  
event-driven-photo-pipeline-dev-alerts

Optional email subscription can be enabled through Terraform variable:
- `alert_email`

## Dashboard Details

**Dashboard name**  
event-driven-photo-pipeline-dev-observability

Widgets include:
- Lambda errors, throttles, invocations
- Lambda average duration and p95 duration
- Lambda concurrent executions
- SQS visible messages
- SQS oldest message age
- DLQ visible messages
- Processing success/failure custom metrics

## Assumptions / Notes for Next Thread

- Log metric filters assume structured JSON logs contain:
  - `{"event":"processing_success"}`
  - `{"event":"processing_failed"}`
- If the application uses a different JSON key, update the metric filter patterns before deployment.
- Observability was implemented without redesigning infrastructure or application flow.

## Next Thread

**CI/CD THREAD**

The CI/CD thread should implement:

- GitHub Actions pipeline
- Terraform validate / plan / apply workflow
- Lambda packaging automation
- Docker build for Lambda layer
- safe deployment pipeline
- GitHub OIDC to AWS IAM role authentication