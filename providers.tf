terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend configuration
  # Override in environment-specific backend.tfvars
  backend "s3" {
    encrypt        = true
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Industrial-Equipment-Marketplace"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "industrial-openapi-iac"
    }
  }
}

# Provider for additional regions (for multi-region deployment)
provider "aws" {
  alias  = "secondary_region"
  region = var.secondary_region

  default_tags {
    tags = {
      Project     = "Industrial-Equipment-Marketplace"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "industrial-openapi-iac"
    }
  }
}



