# Outputs for networking module
# TODO: Add actual outputs as needed

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
