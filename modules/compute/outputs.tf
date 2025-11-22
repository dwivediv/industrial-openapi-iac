# Outputs for compute module
# TODO: Add actual outputs as needed

# Outputs required by main.tf
output "ecs_cluster_name" {
  description = "ECS cluster name (stub)"
  value       = "${var.project_name}-${var.environment}-cluster"
}

output "alb_dns_name" {
  description = "ALB DNS name (stub)"
  value       = "stub-alb.us-east-1.elb.amazonaws.com"
}

output "alb_arn" {
  description = "ALB ARN (stub)"
  value       = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/stub"
}
