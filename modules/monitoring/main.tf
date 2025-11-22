# CloudWatch Dashboard Module
# This module creates CloudWatch dashboards for infrastructure and customer experience KPIs

resource "aws_cloudwatch_dashboard" "infrastructure_compute" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure-compute"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/infrastructure/compute-dashboard.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "infrastructure_database" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure-database"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/infrastructure/database-dashboard.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "infrastructure_networking" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure-networking"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/infrastructure/networking-dashboard.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "infrastructure_cost" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure-cost"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/infrastructure/cost-dashboard.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "customer_experience_api" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-customer-experience-api"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/customer-experience/api-performance.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "customer_experience_ux" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-customer-experience-ux"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/customer-experience/user-experience.json")).widgets
  })

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "customer_experience_business" {
  count          = var.enable_dashboards ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-customer-experience-business"
  dashboard_body = jsonencode({
    widgets = jsondecode(file("${path.module}/../../../dashboards/customer-experience/business-metrics.json")).widgets
  })

  tags = var.tags
}

# CloudWatch Alarms for infrastructure KPIs
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  count               = var.enable_alerts ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-api-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "p95"
  threshold           = 500
  alarm_description   = "API Gateway latency exceeds 500ms"
  alarm_actions       = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ApiName = var.api_gateway_id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_error_rate" {
  count               = var.enable_alerts ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-api-error-rate-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "API Gateway 5XX errors exceed threshold"
  alarm_actions       = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ApiName = var.api_gateway_id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = var.enable_alerts ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS CPU utilization exceeds 80%"
  alarm_actions       = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }

  tags = var.tags
}

resource "aws_sns_topic" "alerts" {
  count = var.enable_alerts && var.alert_email != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.enable_alerts && var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

