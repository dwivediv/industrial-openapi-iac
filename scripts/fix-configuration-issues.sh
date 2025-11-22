#!/bin/bash

# Script to fix configuration issues and create module stubs
# This allows Terraform validation to work even without full module implementations

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Configuration Fix Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to create module stub
create_module_stub() {
    local module_name=$1
    local module_path="modules/$module_name"
    
    if [ ! -f "$module_path/main.tf" ]; then
        echo -e "${YELLOW}Creating stub for module: ${module_name}${NC}"
        
        # Create main.tf stub
        cat > "$module_path/main.tf" <<EOF
# TODO: Implement ${module_name} module
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Outputs (stubs)
output "id" {
  description = "Module ID (stub)"
  value       = "\${var.project_name}-\${var.environment}-${module_name}"
}
EOF

        # Create variables.tf stub
        cat > "$module_path/variables.tf" <<EOF
# Variables for ${module_name} module
# TODO: Add actual variables as needed
EOF

        # Create outputs.tf stub
        cat > "$module_path/outputs.tf" <<EOF
# Outputs for ${module_name} module
# TODO: Add actual outputs as needed
EOF
        
        echo -e "${GREEN}✓ Created stubs for ${module_name}${NC}"
    else
        echo -e "${GREEN}✓ Module ${module_name} already has main.tf${NC}"
    fi
}

# Create stubs for missing modules
echo -e "${YELLOW}Creating module stubs...${NC}"
echo ""

create_module_stub "networking"
create_module_stub "security"
create_module_stub "database"
create_module_stub "compute"
create_module_stub "storage"

echo ""
echo -e "${GREEN}✓ All module stubs created${NC}"
echo ""

# Create networking module with basic outputs that main.tf expects
echo -e "${YELLOW}Creating networking module outputs...${NC}"
cat >> "modules/networking/outputs.tf" <<EOF

# Outputs required by main.tf
output "vpc_id" {
  description = "VPC ID (stub)"
  value       = "vpc-stub"
}

output "private_subnet_ids" {
  description = "Private subnet IDs (stub)"
  value       = ["subnet-stub-1", "subnet-stub-2"]
}

output "public_subnet_ids" {
  description = "Public subnet IDs (stub)"
  value       = ["subnet-stub-1", "subnet-stub-2"]
}

output "alb_security_group_id" {
  description = "ALB security group ID (stub)"
  value       = "sg-stub"
}
EOF

# Create security module outputs
cat >> "modules/security/outputs.tf" <<EOF

# Outputs required by main.tf
output "ecs_task_role_arn" {
  description = "ECS task role ARN (stub)"
  value       = "arn:aws:iam::123456789012:role/stub"
}

output "cognito_pool_id" {
  description = "Cognito user pool ID (stub)"
  value       = "us-east-1_stub"
}
EOF

# Create database module outputs
cat >> "modules/database/outputs.tf" <<EOF

# Outputs required by main.tf
output "equipment_table_name" {
  description = "DynamoDB equipment table name (stub)"
  value       = "\${var.project_name}-\${var.environment}-equipment"
}

output "redis_endpoint" {
  description = "Redis endpoint (stub)"
  value       = "redis-stub.cache.amazonaws.com:6379"
}

output "redis_cluster_id" {
  description = "Redis cluster ID (stub)"
  value       = "redis-stub"
}
EOF

# Create compute module outputs
cat >> "modules/compute/outputs.tf" <<EOF

# Outputs required by main.tf
output "ecs_cluster_name" {
  description = "ECS cluster name (stub)"
  value       = "\${var.project_name}-\${var.environment}-cluster"
}

output "alb_dns_name" {
  description = "ALB DNS name (stub)"
  value       = "stub-alb.us-east-1.elb.amazonaws.com"
}

output "alb_arn" {
  description = "ALB ARN (stub)"
  value       = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/stub"
}
EOF

# Create API Gateway module stub in networking/api-gateway
mkdir -p "modules/networking/api-gateway"
cat > "modules/networking/api-gateway/main.tf" <<EOF
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
EOF

echo -e "${GREEN}✓ Created API Gateway module stub${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Configuration fixes completed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} These are stub files for validation purposes."
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Install prerequisites: ./scripts/validate-prerequisites.sh"
echo "  2. Once Terraform is installed, run: make validate"
echo "  3. Implement actual module logic to replace stubs"
echo ""

