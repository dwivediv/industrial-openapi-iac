# Local Testing Guide

## Overview

This guide explains how to test the Infrastructure as Code (IAC) locally using LocalStack before deploying to AWS.

## Prerequisites

1. **Docker**: Install Docker Desktop
   ```bash
   # Check Docker installation
   docker --version
   docker-compose --version
   ```

2. **Terraform**: >= 1.5.0
   ```bash
   # Install Terraform
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads
   ```

3. **AWS CLI**: For interacting with LocalStack
   ```bash
   # Install AWS CLI
   brew install awscli  # macOS
   ```

4. **jq**: For JSON parsing
   ```bash
   brew install jq
   ```

5. **Make**: For running commands (usually pre-installed)
   ```bash
   make --version
   ```

6. **Optional Tools**:
   - **tflint**: Terraform linter
     ```bash
     brew install tflint
     ```

---

## Quick Start

### 1. Start LocalStack

```bash
# Start LocalStack container
make localstack-start

# Or manually
docker-compose up -d localstack
```

### 2. Verify LocalStack is Running

```bash
# Check health
make localstack-health

# Or manually
curl http://localhost:4566/_localstack/health | jq '.'
```

### 3. Validate Terraform Configuration

```bash
# Validate all environments
make validate

# Or validate specific environment
cd environments/dev
terraform init -backend=false
terraform validate
```

### 4. Test with LocalStack

```bash
# Plan infrastructure
make plan-local

# Apply infrastructure (if plan looks good)
make apply-local

# Destroy infrastructure after testing
make destroy-local
```

---

## Testing Workflow

### Step 1: Start LocalStack

```bash
make localstack-start
```

This will:
- Start LocalStack Docker container
- Wait for services to be ready
- Create S3 bucket for Terraform state
- Create DynamoDB table for state locking

### Step 2: Validate Configuration

```bash
# Format Terraform files
make fmt

# Validate syntax
make validate

# Lint (if tflint is installed)
make lint
```

### Step 3: Test Terraform Plan

```bash
# Set LocalStack environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Navigate to environment
cd environments/dev

# Initialize with LocalStack backend
terraform init -backend-config=backend.tfvars.local

# Plan (dry-run)
terraform plan -var-file=terraform.tfvars.local
```

### Step 4: Apply to LocalStack

```bash
# Apply (creates resources in LocalStack)
terraform apply -var-file=terraform.tfvars.local

# Review created resources
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### Step 5: Verify Resources

```bash
# List VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs

# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List DynamoDB tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# List ECS clusters (if ECS service is enabled)
aws --endpoint-url=http://localhost:4566 ecs list-clusters

# List Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# List API Gateways
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis
```

### Step 6: Clean Up

```bash
# Destroy resources
terraform destroy -var-file=terraform.tfvars.local

# Stop LocalStack
make localstack-stop

# Clean local data
make clean
```

---

## What Can Be Tested Locally

### ✅ Fully Supported Services

- **S3**: Bucket creation, policies, versioning
- **DynamoDB**: Table creation, indexes, TTL
- **Lambda**: Function creation, invocation
- **API Gateway**: REST APIs, routes, integrations
- **IAM**: Roles, policies, users
- **CloudWatch**: Logs, metrics (basic)
- **Secrets Manager**: Secret creation, retrieval
- **SQS**: Queue creation, messages
- **SNS**: Topic creation, subscriptions

### ⚠️ Partially Supported Services

- **ECS**: Basic cluster/task creation (limited)
- **RDS**: Basic instance creation (limited)
- **ElastiCache**: Basic instance creation (limited)
- **CloudFront**: Configuration only (no actual CDN)
- **VPC**: Basic networking (limited)

### ❌ Not Supported Services

- **DAX**: Not supported (use DynamoDB directly)
- **Aurora Serverless**: Not supported (use RDS)
- **OpenSearch**: Not supported (use local Elasticsearch)
- **Multi-region**: Limited support (single region only)

---

## Testing Specific Modules

### Testing Networking Module

```bash
# Test VPC creation
cd modules/networking
terraform init
terraform plan
terraform apply
terraform destroy
```

### Testing Database Module

```bash
# Test DynamoDB table creation
cd modules/database
terraform init
terraform plan
terraform apply

# Verify table
aws --endpoint-url=http://localhost:4566 dynamodb describe-table \
  --table-name equipment
```

### Testing Monitoring Module

```bash
# Test CloudWatch dashboard creation
cd modules/monitoring
terraform init
terraform plan

# Note: Dashboards may not fully work in LocalStack
# Focus on validating Terraform configuration
```

---

## Automated Testing

### Using Terratest (Go)

Create test files in `tests/` directory:

```go
// tests/test_networking.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestNetworkingModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
        EnvVars: map[string]string{
            "AWS_ACCESS_KEY_ID": "test",
            "AWS_SECRET_ACCESS_KEY": "test",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Add assertions
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

Run tests:
```bash
cd tests
go test -v
```

---

## Troubleshooting

### LocalStack Not Starting

```bash
# Check Docker is running
docker ps

# Check LocalStack logs
make localstack-logs

# Restart LocalStack
make localstack-stop
make localstack-start
```

### Terraform Backend Issues

```bash
# Verify S3 bucket exists
aws --endpoint-url=http://localhost:4566 s3 ls

# Verify DynamoDB table exists
aws --endpoint-url=http://localhost:4566 dynamodb describe-table \
  --table-name terraform-state-lock

# Recreate backend
make setup-localstack-backend
```

### Service Not Available

```bash
# Check LocalStack health
make localstack-health

# Verify service is enabled in docker-compose.yml
# SERVICES should include the service name
```

### Port Already in Use

```bash
# Change LocalStack port in docker-compose.yml
ports:
  - "4567:4566"  # Use different host port

# Update endpoint in backend.tfvars.local
endpoint = "http://localhost:4567"
```

---

## Best Practices

1. **Always Validate First**: Run `make validate` before testing
2. **Start Small**: Test individual modules before full environment
3. **Clean Up**: Always destroy resources after testing
4. **Use Test Variables**: Use `terraform.tfvars.local` for local testing
5. **Monitor Logs**: Check LocalStack logs for issues
6. **Version Control**: Don't commit `.terraform/` or state files

---

## Limitations

1. **Not 100% Compatible**: LocalStack doesn't support all AWS features
2. **Performance**: LocalStack is slower than real AWS
3. **Persistence**: Data persists in containers (use volumes)
4. **Multi-Region**: Limited multi-region support
5. **Cost Simulation**: No cost tracking in LocalStack

---

## Next Steps

After successful local testing:

1. **Review Changes**: Ensure all changes are committed
2. **Update Variables**: Update `terraform.tfvars` with real values
3. **Test in Dev**: Deploy to dev environment in AWS
4. **Validate**: Compare LocalStack vs AWS behavior
5. **Deploy**: Proceed with deployment to higher environments

---

## References

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Terraform Testing](https://www.terraform.io/docs/language/modules/testing.html)
- [Terratest](https://terratest.gruntwork.io/)
- [Docker Compose](https://docs.docker.com/compose/)



