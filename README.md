# Event Driven Photo Processing Pipeline

## 1. Project Overview

This project implements a production-oriented, event-driven photo processing pipeline on AWS. It demonstrates how to design a decoupled, observable, and infrastructure-as-code–managed system suitable for mid-level cloud engineering roles.

The system ingests uploaded images, processes them asynchronously, stores outputs, and records metadata—while maintaining resilience, traceability, and operational visibility.

---

## 2. Architecture Diagram
            ┌────────────────────┐
            │   Client Upload    │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │   S3 Raw Bucket    │
            │   (uploads/)       │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │   EventBridge      │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │     SQS Queue      │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │   Lambda Processor │
            │   (Python 3.11)    │
            └───────┬─────┬──────┘
                    │     │
                    ▼     ▼
    ┌──────────────────┐   ┌────────────────────┐
    │ S3 Processed     │   │ DynamoDB           │
    │ Bucket (photos/) │   │ Metadata Table     │
    └──────────────────┘   └────────────────────┘

            ┌────────────────────┐
            │       DLQ          │
            └────────────────────┘

---

## 3. Architecture Explanation

The system follows an event-driven pattern to decouple ingestion from processing:

- Images are uploaded to an S3 raw bucket.
- S3 events are routed through EventBridge to an SQS queue.
- SQS buffers and decouples processing from ingestion spikes.
- Lambda consumes messages, processes images using Pillow, and:
  - Stores processed images in a separate S3 bucket
  - Writes metadata to DynamoDB
- Failed messages are routed to a Dead Letter Queue (DLQ) for investigation.

This design ensures scalability, fault isolation, and operational resilience.

---

## 4. Tech Stack

- **Cloud Provider:** AWS (eu-west-1)
- **Compute:** AWS Lambda (Python 3.11)
- **Storage:** S3 (raw + processed)
- **Database:** DynamoDB
- **Messaging:** EventBridge + SQS + DLQ
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions
- **Monitoring:** CloudWatch (logs, metrics, alarms, dashboards)
- **Image Processing:** Pillow (Lambda Layer)

---

## 5. Infrastructure (Terraform)

All infrastructure is defined and managed using Terraform.

Key components:
- S3 buckets (raw + processed)
- SQS queue + DLQ
- EventBridge rule and target
- Lambda function and IAM role
- DynamoDB table
- CloudWatch alarms and dashboard

Terraform ensures:
- Reproducibility of environments
- Version-controlled infrastructure
- Clear dependency management

---

## 6. Remote State & Why It Matters

Terraform state is stored remotely using:
- **S3 bucket** (state storage)
- **DynamoDB table** (state locking)

### Why this matters:

- Prevents state loss (no reliance on local `.tfstate`)
- Enables safe collaboration across environments
- Avoids concurrent apply conflicts via locking
- Allows CI/CD pipelines to safely interact with infrastructure

Without remote state, CI/CD deployments are unsafe and non-deterministic.

---

## 7. CI/CD Pipeline

Implemented using GitHub Actions.

### Pipeline Steps:

1. Package Lambda (PowerShell script)
2. `terraform init`
3. `terraform fmt -check`
4. `terraform validate`
5. `terraform plan`

### Key Decision: Plan-Only Strategy

Terraform **apply is intentionally disabled** in CI.

#### Rationale:
- Prevents accidental infrastructure mutation
- Ensures human validation before changes
- Avoids drift issues during early-stage development
- Aligns with controlled deployment practices

The pipeline validates infrastructure quality without introducing deployment risk.

---

## 8. Observability & Monitoring

Observability is built into the system from the start.

### Logging
- Structured logs emitted from Lambda
- Centralized in CloudWatch Logs

### Metrics & Alerts
Custom and native metrics monitored:
- Lambda errors
- Lambda throttles
- Duration (p95)
- SQS queue depth
- DLQ message count

### Alarms
Configured for:
- Error spikes
- Performance degradation
- Backlog accumulation
- Failed processing (DLQ)

### Dashboard
A CloudWatch dashboard provides:
- Real-time system visibility
- Operational health overview
- Debugging entry point

---

## 9. Security Considerations

- IAM roles follow least-privilege principles
- Lambda permissions scoped to:
  - Specific S3 buckets
  - Specific DynamoDB table
  - SQS queue consumption
- EventBridge → SQS permissions explicitly configured
- No public exposure of internal resources

This reduces blast radius and aligns with AWS security best practices.

---

## 10. How to Deploy (Local Only)

### Prerequisites
- AWS CLI configured
- Terraform installed
- PowerShell (for packaging script)

### Steps

```bash
# 1. Package Lambda
./scripts/package_lambda.ps1

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform validate

# 4. Review changes
terraform plan

# 5. Apply (manual step)
terraform apply