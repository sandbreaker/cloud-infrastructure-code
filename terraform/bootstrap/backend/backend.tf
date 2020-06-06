/* 
Custom configuration definition here
IMPORTANT: bucket name must be unique, not just for this account, but everything out there
*/
locals {
  terra_state_s3_bucket = "sandbreaker-terraform-state"
}

/*
Use AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env variable
*/
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.52"
}

/*
S3 remote state store
*/
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.terra_state_s3_bucket}"

  # important to set true!
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

/*
Dynamodb table for locking the terraform state file
*/
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terra-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  # read_capacity  = 20
  # write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

