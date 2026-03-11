terraform {
  backend "s3" {
    bucket         = "event-driven-photo-pipeline-tf-state"
    key            = "event-driven-photo-pipeline/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "event-driven-photo-pipeline-tf-locks"
    encrypt        = true
  }
}
