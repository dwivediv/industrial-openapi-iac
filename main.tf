# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )

  # Environment-specific configurations
  is_production = var.environment == "production"
  is_dev        = var.environment == "dev"
  is_test       = var.environment == "test"
  is_integration = var.environment == "integration"

  # Scaling configuration based on environment
  ecs_min_capacity = local.is_production ? var.production_min_capacity : var.min_ecs_capacity
  ecs_max_capacity = local.is_production ? var.production_max_capacity : var.max_ecs_capacity
  ecs_desired_capacity = local.is_production ? var.production_min_capacity : var.desired_ecs_capacity

  # Cost optimization settings
  spot_enabled = var.enable_spot_instances && !local.is_production # Spot for non-prod
  spot_percentage = local.spot_enabled ? var.spot_instance_percentage : 0

  # Database settings
  dax_enabled = local.is_production && var.enable_dax
  dax_nodes   = local.is_production ? var.dax_node_count : 3

  # Redis settings
  redis_nodes = local.is_production ? var.redis_node_count : 3
  redis_reserved = local.is_production && var.use_reserved_instances

  # Aurora settings
  aurora_min = local.is_production ? var.aurora_min_capacity : 2
  aurora_max = local.is_production ? var.aurora_max_capacity : 8
}

# VPC Module
module "networking" {
  source = "./modules/networking"

  environment     = var.environment
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  aws_region      = var.aws_region
  enable_multi_az = true

  tags = local.common_tags
}

# Security Module (IAM, Cognito, WAF, Secrets)
module "security" {
  source = "./modules/security"

  environment      = var.environment
  project_name     = var.project_name
  aws_region       = var.aws_region
  aws_account_id   = data.aws_caller_identity.current.account_id

  tags = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  environment           = var.environment
  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  enable_dax            = local.dax_enabled
  dax_node_count        = local.dax_nodes
  redis_node_count      = local.redis_nodes
  use_reserved_instances = local.redis_reserved
  aurora_min_capacity   = local.aurora_min
  aurora_max_capacity   = local.aurora_max

  tags = local.common_tags
}

# Compute Module (ECS Fargate, Lambda)
module "compute" {
  source = "./modules/compute"

  environment            = var.environment
  project_name           = var.project_name
  aws_region             = var.aws_region
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  public_subnet_ids      = module.networking.public_subnet_ids
  alb_security_group_id  = module.networking.alb_security_group_id
  min_capacity           = local.ecs_min_capacity
  max_capacity           = local.ecs_max_capacity
  desired_capacity       = local.ecs_desired_capacity
  enable_spot_instances  = local.spot_enabled
  spot_percentage        = local.spot_percentage
  enable_scheduled_scaling = var.enable_scheduled_scaling
  iam_role_arn           = module.security.ecs_task_role_arn
  dynamodb_table_name    = module.database.equipment_table_name
  redis_endpoint         = module.database.redis_endpoint

  tags = local.common_tags
}

# Storage Module (S3, CloudFront)
module "storage" {
  source = "./modules/storage"

  environment  = var.environment
  project_name = var.project_name
  aws_region   = var.aws_region
  alb_dns_name = module.compute.alb_dns_name

  tags = local.common_tags
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/networking/api-gateway"

  environment    = var.environment
  project_name   = var.project_name
  aws_region     = var.aws_region
  alb_dns_name   = module.compute.alb_dns_name
  cognito_pool_id = module.security.cognito_pool_id
  enable_caching = true
  cache_size     = local.is_production ? 500 : 100

  tags = local.common_tags
}

# Monitoring Module (CloudWatch, X-Ray, Dashboards)
module "monitoring" {
  source = "./modules/monitoring"

  environment               = var.environment
  project_name              = var.project_name
  aws_region                = var.aws_region
  enable_dashboards         = var.enable_cloudwatch_dashboards
  enable_alerts             = var.enable_alerts
  alert_email               = var.alert_email
  slack_webhook_url         = var.slack_webhook_url
  ecs_cluster_name          = module.compute.ecs_cluster_name
  api_gateway_id            = module.api_gateway.api_gateway_id
  dynamodb_table_name       = module.database.equipment_table_name
  redis_cluster_id          = module.database.redis_cluster_id
  alb_arn                   = module.compute.alb_arn

  tags = local.common_tags

  depends_on = [
    module.compute,
    module.api_gateway,
    module.database
  ]
}

# Secondary region deployment (production only)
module "production_secondary_region" {
  count  = local.is_production && var.enable_multi_region ? 1 : 0
  source = "./modules/networking"

  providers = {
    aws = aws.secondary_region
  }

  environment     = var.environment
  project_name    = var.project_name
  vpc_cidr        = "10.1.0.0/16" # Different CIDR for secondary region
  aws_region      = var.secondary_region
  enable_multi_az = true

  tags = merge(local.common_tags, {
    Region = "secondary"
  })
}



