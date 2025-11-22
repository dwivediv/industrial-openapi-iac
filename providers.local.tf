# Local Provider Configuration for LocalStack Testing
# This file overrides providers.tf for local testing

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # LocalStack backend configuration
  backend "s3" {
    bucket                  = "terraform-state-local"
    key                     = "terraform.tfstate"
    region                  = "us-east-1"
    dynamodb_table          = "terraform-state-lock"
    endpoint                = "http://localhost:4566"
    access_key              = "test"
    secret_key              = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Project     = "Industrial-Equipment-Marketplace"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "industrial-openapi-iac"
      Testing     = "LocalStack"
    }
  }
}

