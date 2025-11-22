# CloudWatch Dashboards Documentation

## Overview

This document describes the CloudWatch dashboards created for monitoring infrastructure and customer experience KPIs for the Industrial Equipment Marketplace.

## Dashboard Categories

### 1. Infrastructure Dashboards

Infrastructure dashboards monitor the health, performance, and cost of AWS resources.

#### Compute Dashboard (`infrastructure-compute`)
**Purpose**: Monitor ECS Fargate, Lambda, and ALB metrics

**Metrics:**
- **ECS CPU/Memory Utilization**: Average CPU and memory usage across tasks
- **ECS Task Count**: Running, desired, and pending task counts
- **Lambda Invocations**: Total invocations, errors, and duration
- **ALB Response Time**: Target response time (p95) and request counts

**Location**: `dashboards/infrastructure/compute-dashboard.json`

---

#### Database Dashboard (`infrastructure-database`)
**Purpose**: Monitor DynamoDB, DAX, Redis, RDS, and OpenSearch metrics

**Metrics:**
- **DynamoDB**: Consumed read/write capacity, throttled requests
- **DAX**: Cache hits, misses, and cache hit rate
- **ElastiCache Redis**: CPU, network bytes, cache hits/misses
- **Aurora PostgreSQL**: CPU, connections, read/write latency (p95)
- **OpenSearch**: Search latency (p95), indexing latency, cluster status

**Location**: `dashboards/infrastructure/database-dashboard.json`

---

#### Networking Dashboard (`infrastructure-networking`)
**Purpose**: Monitor API Gateway, CloudFront, and ALB networking metrics

**Metrics:**
- **API Gateway**: Request count, 4XX/5XX errors, latency (p95)
- **CloudFront**: Requests, bytes downloaded/uploaded, cache hit rate
- **ALB**: Request count, target response time (p95), HTTP status codes
- **API Gateway Cache**: Cache hit/miss counts

**Location**: `dashboards/infrastructure/networking-dashboard.json`

---

#### Cost Dashboard (`infrastructure-cost`)
**Purpose**: Monitor AWS costs and cost by service

**Metrics:**
- **Daily Estimated Charges**: Total daily cost in USD
- **Cost by Service**: Breakdown by service (EC2, DynamoDB, RDS, CloudFront, API Gateway)
- **Resource Utilization vs Cost**: ECS tasks, Lambda invocations, DynamoDB capacity

**Location**: `dashboards/infrastructure/cost-dashboard.json`

---

### 2. Customer Experience Dashboards

Customer experience dashboards monitor the user-facing performance and business metrics.

#### API Performance Dashboard (`customer-experience-api`)
**Purpose**: Monitor API performance from customer perspective

**Metrics:**
- **API Latency Percentiles**: p50, p95, p99 latency
- **Request Count & Errors**: Total requests, 4XX/5XX errors
- **Error Rate**: Error rate percentage with thresholds (0.5%, 1%)
- **Application Response Time**: Target response time percentiles
- **Cache Performance**: API Gateway cache hit/miss counts

**Location**: `dashboards/customer-experience/api-performance.json`

---

#### User Experience Dashboard (`customer-experience-ux`)
**Purpose**: Monitor frontend and user experience metrics

**Metrics:**
- **CloudFront Cache Performance**: Cache hit rate and total requests
- **CloudFront Error Rates**: 4XX and 5XX error rates
- **Page Load Performance**: ALB target response time (p95)
- **Cache Hit Rates**: DAX and Redis cache hit rates
- **Search Performance**: OpenSearch search latency (p95)

**Location**: `dashboards/customer-experience/user-experience.json`

---

#### Business Metrics Dashboard (`customer-experience-business`)
**Purpose**: Monitor business KPIs and user activity

**Metrics:**
- **User Authentication**: Sign-up attempts, sign-in successes, throttles
- **Equipment Count**: Total equipment in DynamoDB
- **API Activity**: Equipment API GET/POST request counts
- **Search Activity**: Search requests and latency
- **Request Trends**: Log-based trends for equipment API requests

**Location**: `dashboards/customer-experience/business-metrics.json`

---

## Dashboard Deployment

Dashboards are automatically deployed via Terraform when `enable_cloudwatch_dashboards = true` in the environment configuration.

### Manual Deployment

If you need to deploy dashboards manually:

```bash
# Deploy infrastructure dashboards
aws cloudwatch put-dashboard \
  --dashboard-name industrial-marketplace-prod-infrastructure-compute \
  --dashboard-body file://dashboards/infrastructure/compute-dashboard.json \
  --region us-east-1

# Deploy customer experience dashboards
aws cloudwatch put-dashboard \
  --dashboard-name industrial-marketplace-prod-customer-experience-api \
  --dashboard-body file://dashboards/customer-experience/api-performance.json \
  --region us-east-1
```

---

## Dashboard Access

### Via AWS Console

1. Navigate to CloudWatch Dashboard
2. Search for dashboard name: `industrial-marketplace-{environment}-*`
3. Open dashboard to view metrics

### Via CLI

```bash
# List all dashboards
aws cloudwatch list-dashboards --region us-east-1

# Get dashboard details
aws cloudwatch get-dashboard \
  --dashboard-name industrial-marketplace-prod-infrastructure-compute \
  --region us-east-1
```

---

## Customizing Dashboards

### Adding New Metrics

1. Edit the JSON dashboard file in `dashboards/` directory
2. Add new metric widget following CloudWatch dashboard format
3. Redeploy via Terraform: `terraform apply`

### Example: Adding Custom Metric

```json
{
  "type": "metric",
  "properties": {
    "metrics": [
      ["AWS/DynamoDB", "UserErrors", {"stat": "Sum"}]
    ],
    "period": 300,
    "stat": "Sum",
    "region": "us-east-1",
    "title": "Custom Metric"
  }
}
```

---

## KPI Targets

### Infrastructure KPIs

| Metric | Target | Threshold |
|--------|--------|-----------|
| API Gateway Latency (p95) | < 50ms | < 500ms |
| ECS CPU Utilization | 40-70% | < 80% |
| ECS Memory Utilization | < 80% | < 90% |
| DynamoDB Throttling | 0 | < 10/min |
| DAX Cache Hit Rate | > 80% | > 70% |
| Redis Cache Hit Rate | > 70% | > 60% |
| CloudFront Cache Hit Rate | > 85% | > 75% |

### Customer Experience KPIs

| Metric | Target | Threshold |
|--------|--------|-----------|
| API Latency (p95) | < 500ms | < 1000ms |
| API Error Rate | < 0.5% | < 1% |
| Page Load Time (p95) | < 2.5s | < 5s |
| Search Latency (p95) | < 500ms | < 1000ms |
| User Sign-In Success Rate | > 99% | > 95% |

---

## Alerting

CloudWatch alarms are automatically created for critical metrics:

- **API Latency**: Alert if p95 > 500ms for 2 consecutive periods
- **API Error Rate**: Alert if 5XX errors > 10 in 5 minutes
- **ECS CPU High**: Alert if CPU > 80% for 2 consecutive periods

Alerts are sent to SNS topic and can be configured for email or Slack notifications.

---

## Cost Monitoring

The cost dashboard provides:
- Daily estimated charges
- Cost breakdown by service
- Resource utilization vs cost correlation

Set up AWS Budgets for automated cost alerts (see MULTI_ACCOUNT_SETUP.md).

---

## Best Practices

1. **Review Daily**: Check dashboards daily for anomalies
2. **Set Alarms**: Use CloudWatch alarms for automated alerting
3. **Customize**: Add custom metrics specific to your use case
4. **Optimize**: Use dashboard insights to identify optimization opportunities
5. **Document**: Document any custom dashboards or metrics added

---

## References

- [CloudWatch Dashboards User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html)
- [CloudWatch Metrics Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
- [Dashboard JSON Format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Dashboard-Body-Structure.html)

