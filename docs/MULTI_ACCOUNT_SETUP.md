# Multi-Account Setup Guide

## Overview

This guide explains how to set up the Industrial Equipment Marketplace infrastructure across multiple AWS accounts for better security, isolation, and cost management.

## Account Structure

### Account 1: Development & Test Account
**Account ID**: `123456789012` (replace with your account ID)

**Environments:**
- **Development (dev)**: Active development environment
- **Test (test)**: QA and staging environment

**Purpose:**
- Isolated from production
- Lower security requirements
- Cost-optimized with Spot instances
- Shared by all developers

**Estimated Monthly Cost**: $1,000-2,000

---

### Account 2: Integration & Production Account
**Account ID**: `987654321098` (replace with your account ID)

**Environments:**
- **Integration (integration)**: Pre-production testing
- **Production (production)**: 
  - **US East (us-east-1)**: Primary region
  - **US West (us-west-2)**: Secondary region (DR)

**Purpose:**
- Isolated from development
- Higher security requirements
- Production-grade reliability
- Restricted access (only DevOps team)

**Estimated Monthly Cost**: $15,500-28,200

---

## Prerequisites

1. **Two AWS Accounts**: One for Dev/Test, one for Integration/Prod
2. **AWS CLI**: Configured with appropriate credentials
3. **Terraform**: >= 1.5.0
4. **IAM Permissions**: Appropriate permissions in both accounts
5. **S3 Buckets**: For Terraform remote state (one per account)
6. **DynamoDB Tables**: For state locking (one per account)

---

## Step 1: Setup Remote State Backend

### For Account 1 (Dev/Test Account)

```bash
# Login to Dev/Test account
aws configure --profile dev-test

# Create S3 bucket for remote state
aws s3 mb s3://terraform-state-dev-account --region us-east-1 --profile dev-test

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-dev-account \
  --versioning-configuration Status=Enabled \
  --profile dev-test

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-dev-account \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --profile dev-test

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1 \
  --profile dev-test
```

### For Account 2 (Integration/Prod Account)

```bash
# Login to Integration/Prod account
aws configure --profile integration-prod

# Create S3 bucket for remote state
aws s3 mb s3://terraform-state-prod-account --region us-east-1 --profile integration-prod

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-prod-account \
  --versioning-configuration Status=Enabled \
  --profile integration-prod

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-prod-account \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --profile integration-prod

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1 \
  --profile integration-prod
```

---

## Step 2: Configure AWS Profiles

Update `~/.aws/credentials`:

```ini
[dev-test]
aws_access_key_id = YOUR_DEV_TEST_ACCESS_KEY
aws_secret_access_key = YOUR_DEV_TEST_SECRET_KEY
region = us-east-1

[integration-prod]
aws_access_key_id = YOUR_INTEGRATION_PROD_ACCESS_KEY
aws_secret_access_key = YOUR_INTEGRATION_PROD_SECRET_KEY
region = us-east-1
```

---

## Step 3: Update Environment Configurations

### Update Account IDs

1. **Dev/Test Account** (`environments/dev/terraform.tfvars` and `environments/test/terraform.tfvars`):
   ```hcl
   aws_account_id = "123456789012" # Replace with your Dev/Test account ID
   ```

2. **Integration/Prod Account** (`environments/integration/terraform.tfvars` and `environments/production/*/terraform.tfvars`):
   ```hcl
   aws_account_id = "987654321098" # Replace with your Integration/Prod account ID
   ```

---

## Step 4: Deploy Environments

### Deploy to Dev/Test Account

```bash
# Deploy Development environment
cd environments/dev
export AWS_PROFILE=dev-test
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply

# Deploy Test environment
cd ../test
export AWS_PROFILE=dev-test
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

### Deploy to Integration/Prod Account

```bash
# Deploy Integration environment
cd environments/integration
export AWS_PROFILE=integration-prod
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply

# Deploy Production US East (Primary)
cd ../production/us-east-1
export AWS_PROFILE=integration-prod
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply

# Deploy Production US West (Secondary/DR)
cd ../us-west-2
export AWS_PROFILE=integration-prod
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

---

## Step 5: Cross-Account Access (Optional)

If you need cross-account access (e.g., for monitoring, backup, or CI/CD):

### Create IAM Role for Cross-Account Access

In **Account 2** (Integration/Prod):

```hcl
# Allow Account 1 to assume role for monitoring
resource "aws_iam_role" "cross_account_monitoring" {
  name = "CrossAccountMonitoringRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root" # Account 1
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "unique-external-id"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cross_account_readonly" {
  role = aws_iam_role.cross_account_monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}
```

---

## Security Best Practices

### 1. IAM Roles
- Use IAM roles instead of access keys where possible
- Implement least privilege access
- Enable MFA for production account access

### 2. Network Isolation
- Use separate VPCs for each environment
- Implement VPC peering or Transit Gateway if needed
- Use security groups and NACLs for network isolation

### 3. Encryption
- Enable encryption at rest for all data stores
- Use TLS/SSL for all data in transit
- Enable S3 bucket encryption for remote state

### 4. Monitoring
- Enable CloudTrail in both accounts
- Enable GuardDuty for threat detection
- Set up Config for compliance monitoring

### 5. Access Control
- Use AWS Organizations for account management
- Implement Service Control Policies (SCPs)
- Use AWS SSO for centralized access management

---

## Cost Management

### Account 1 (Dev/Test)
- **Cost Optimization**: Use Spot instances (70% of capacity)
- **Estimated Cost**: $1,000-2,000/month
- **Billing Alert**: Set up at $1,500/month

### Account 2 (Integration/Prod)
- **Cost Optimization**: Reserved instances for production, scheduled scaling
- **Estimated Cost**: $15,500-28,200/month
- **Billing Alert**: Set up at $25,000/month

### Budget Alerts

```bash
# Create budget alert for Dev/Test account
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budgets/dev-test-budget.json \
  --notifications-with-subscribers file://budgets/dev-test-notifications.json \
  --profile dev-test

# Create budget alert for Integration/Prod account
aws budgets create-budget \
  --account-id 987654321098 \
  --budget file://budgets/integration-prod-budget.json \
  --notifications-with-subscribers file://budgets/integration-prod-notifications.json \
  --profile integration-prod
```

---

## Troubleshooting

### Common Issues

1. **State Lock Error**: Another Terraform operation is running
   ```bash
   # Force unlock (use with caution)
   terraform force-unlock <LOCK_ID>
   ```

2. **Access Denied**: Check IAM permissions and AWS profile
   ```bash
   # Verify AWS profile
   aws sts get-caller-identity --profile dev-test
   ```

3. **Backend Configuration Error**: Verify S3 bucket and DynamoDB table exist
   ```bash
   # Check S3 bucket
   aws s3 ls s3://terraform-state-dev-account --profile dev-test
   
   # Check DynamoDB table
   aws dynamodb describe-table --table-name terraform-state-lock-dev --profile dev-test
   ```

---

## Next Steps

1. Set up CI/CD pipeline for automated deployments
2. Configure cross-account monitoring and alerting
3. Implement backup and disaster recovery procedures
4. Set up cost optimization monitoring
5. Configure security monitoring and compliance

---

## References

- [AWS Organizations Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)
- [Terraform Remote State](https://www.terraform.io/docs/language/state/remote.html)
- [AWS Multi-Account Strategy](https://aws.amazon.com/organizations/getting-started/best-practices/)



