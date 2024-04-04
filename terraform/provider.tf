terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "eks-wiz-567-terraform-state"
    key            = "eks-wiz-567-terraform-state"
    region         = "us-east-1"
    dynamodb_table = "eks-wiz-567-terraform-state-lock-dynamo"
  }
}


provider "aws" {
  region = "us-east-1"
}
