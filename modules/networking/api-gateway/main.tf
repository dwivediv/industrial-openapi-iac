# TODO: Implement API Gateway module
# This is a stub file for validation purposes

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "cognito_pool_id" {
  description = "Cognito user pool ID"
  type        = string
  default     = ""
}

variable "enable_caching" {
  description = "Enable API Gateway caching"
  type        = bool
  default     = false
}

variable "cache_size" {
  description = "Cache size in MB"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

output "api_gateway_id" {
  description = "API Gateway ID (stub)"
  value       = "stub-api-gateway-id"
}
