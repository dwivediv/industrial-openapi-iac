variable "aws_region" {
  description = "AWS region for primary deployment"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "AWS region for secondary deployment (production DR)"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, test, integration, production)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "integration", "production"], var.environment)
    error_message = "Environment must be one of: dev, test, integration, production"
  }
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "industrial-marketplace"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment (production only)"
  type        = bool
  default     = false
}

variable "enable_spot_instances" {
  description = "Enable ECS Fargate Spot instances"
  type        = bool
  default     = true
}

variable "spot_instance_percentage" {
  description = "Percentage of ECS capacity to use Spot instances"
  type        = number
  default     = 70
  validation {
    condition     = var.spot_instance_percentage >= 0 && var.spot_instance_percentage <= 100
    error_message = "Spot instance percentage must be between 0 and 100"
  }
}

variable "enable_cloudwatch_dashboards" {
  description = "Enable CloudWatch dashboards"
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

# Scaling variables
variable "min_ecs_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 2
}

variable "max_ecs_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 50
}

variable "desired_ecs_capacity" {
  description = "Desired ECS task count"
  type        = number
  default     = 5
}

# Production scaling (100K users)
variable "production_min_capacity" {
  description = "Minimum ECS capacity for production"
  type        = number
  default     = 50
}

variable "production_max_capacity" {
  description = "Maximum ECS capacity for production"
  type        = number
  default     = 500
}

# Database variables
variable "enable_dax" {
  description = "Enable DynamoDB DAX cluster"
  type        = bool
  default     = false
}

variable "dax_node_count" {
  description = "Number of DAX nodes"
  type        = number
  default     = 3
}

variable "redis_node_count" {
  description = "Number of Redis nodes"
  type        = number
  default     = 3
}

variable "aurora_min_capacity" {
  description = "Minimum Aurora Serverless v2 ACUs"
  type        = number
  default     = 2
}

variable "aurora_max_capacity" {
  description = "Maximum Aurora Serverless v2 ACUs"
  type        = number
  default     = 8
}

# Cost optimization
variable "use_reserved_instances" {
  description = "Use Reserved Instances for Redis (production only)"
  type        = bool
  default     = false
}

variable "enable_scheduled_scaling" {
  description = "Enable scheduled scaling (scale down during off-peak hours)"
  type        = bool
  default     = false
}

# Monitoring
variable "alert_email" {
  description = "Email address for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for alerts (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

