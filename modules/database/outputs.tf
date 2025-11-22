# Outputs for database module
# TODO: Add actual outputs as needed

# Outputs required by main.tf
output "equipment_table_name" {
  description = "DynamoDB equipment table name (stub)"
  value       = "${var.project_name}-${var.environment}-equipment"
}

output "redis_endpoint" {
  description = "Redis endpoint (stub)"
  value       = "redis-stub.cache.amazonaws.com:6379"
}

output "redis_cluster_id" {
  description = "Redis cluster ID (stub)"
  value       = "redis-stub"
}
