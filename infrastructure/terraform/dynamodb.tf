resource "aws_dynamodb_table" "photo_metadata" {
  name         = "event-driven-photo-pipeline-dev-photo-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}