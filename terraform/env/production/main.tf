/* 
Custom configuration definition here
*/
locals {
  aws_region = "us-east-1"
  env        = "production"
  corp       = "yourcorp"
}

/*
Set environment variables
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION (optional)
*/
provider "aws" {
  version = "~> 2.52"
  region  = local.aws_region
}

/* 
Terraform s3 based reference storage.
NOTE: you must boostrap s3+dynamodb from boostrap/backend first
NOTE: you cannot use variables in terraform block
*/
terraform {
  backend "s3" {
    # this is the backend terraform state file s3 bucket name
    bucket         = "sandbreaker-terraform-state"
    key            = "state_us_east_1_production"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terra-lock"
  }
}

/* 
AWS elastic container repo. Can define more as needed like service_backend, web, etc
*/
resource "aws_ecr_repository" "service_frontend" {
  name = "service-frontend-${local.env}"
}

resource "aws_eip" "nat_setup" {
  count = 1 # for now, use single nat gateway per vpc
  vpc   = true
}

/* 
VPC setup, uses terraform vpc module
*/
module "vpc_setup" {
  source = "./../../modules/vpc/"
  name   = "vpc-${local.env}"

  cidr = "10.11.0.0/16"

  azs                 = ["${local.aws_region}a", "${local.aws_region}c"]
  private_subnets     = ["10.11.0.0/24", "10.11.1.0/24"]
  public_subnets      = ["10.11.129.0/24", "10.11.130.0/24"]
  database_subnets    = ["10.11.139.0/24", "10.11.140.0/24"]
  elasticache_subnets = ["10.11.149.0/24", "10.11.150.0/24"]

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # NOTE: always re-use or causes deployment delays/trouble
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat_setup.*.id

  enable_vpn_gateway       = false
  enable_s3_endpoint       = false
  enable_dynamodb_endpoint = false
  enable_dhcp_options      = false

  tags = {
    Owner       = local.corp
    Environment = local.env
    Name        = "vpc-${local.env}"
  }
}
