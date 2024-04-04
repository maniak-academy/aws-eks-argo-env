terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_string" "random" {
  length  = 3 # Length of the string
  special = false # No special characters
  upper   = false # No uppercase characters
  lower   = true  # Include lowercase letters
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.name}-${random_string.random.id}-terraform-state"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "${var.name}-${random_string.random.id}-terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
  attribute {
    name = "LockID"
    type = "S"
  }
}