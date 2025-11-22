# Outputs for security module
# TODO: Add actual outputs as needed

# Outputs required by main.tf
output "ecs_task_role_arn" {
  description = "ECS task role ARN (stub)"
  value       = "arn:aws:iam::123456789012:role/stub"
}

output "cognito_pool_id" {
  description = "Cognito user pool ID (stub)"
  value       = "us-east-1_stub"
}
