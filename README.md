# Industrial Equipment Marketplace - Infrastructure as Code (IAC)

## Overview

This repository contains Infrastructure as Code (IAC) for the Industrial Equipment Marketplace platform using **Terraform**. The infrastructure supports multiple environments with separate AWS accounts for better security, isolation, and cost management.

## Repository Structure

```
industrial-openapi-iac/
├── README.md                          # This file
├── .gitignore
├── terraform.tfvars.example           # Example variables file
├── backend.tf                         # Remote state configuration
├── variables.tf                       # Global variables
├── providers.tf                       # AWS provider configuration
├── main.tf                            # Main infrastructure configuration
│
├── environments/                      # Environment-specific configurations
│   ├── dev/                          # Development environment
│   │   ├── terraform.tfvars
│   │   ├── backend.tfvars
│   │   └── main.tf
│   ├── test/                         # Test environment
│   │   ├── terraform.tfvars
│   │   ├── backend.tfvars
│   │   └── main.tf
│   ├── integration/                  # Integration environment
│   │   ├── terraform.tfvars
│   │   ├── backend.tfvars
│   │   └── main.tf
│   └── production/                   # Production environment
│       ├── us-east-1/               # Production US East
│       │   ├── terraform.tfvars
│       │   ├── backend.tfvars
│       │   └── main.tf
│       └── us-west-2/               # Production US West
│           ├── terraform.tfvars
│           ├── backend.tfvars
│           └── main.tf
│
├── modules/                          # Reusable Terraform modules
│   ├── compute/                     # ECS Fargate, Lambda
│   ├── networking/                  # VPC, ALB, API Gateway, CloudFront
│   ├── database/                    # DynamoDB, RDS, DAX, Redis, OpenSearch
│   ├── security/                    # IAM, Cognito, WAF, Secrets
│   ├── monitoring/                  # CloudWatch, X-Ray, Dashboards
│   └── storage/                     # S3, CloudFront
│
├── dashboards/                      # CloudWatch Dashboard definitions
│   ├── infrastructure/              # Infrastructure KPIs
│   │   ├── compute-dashboard.json
│   │   ├── database-dashboard.json
│   │   ├── networking-dashboard.json
│   │   └── cost-dashboard.json
│   └── customer-experience/         # Customer experience KPIs
│       ├── api-performance.json
│       ├── user-experience.json
│       └── business-metrics.json
│
├── scripts/                         # Helper scripts
│   ├── setup-remote-state.sh       # Setup S3 backend for remote state
│   ├── deploy.sh                   # Deployment script
│   └── switch-env.sh               # Switch between environments
│
└── docs/                            # Documentation
    ├── ENVIRONMENT_SETUP.md        # Environment setup guide
    ├── DEPLOYMENT.md               # Deployment guide
    ├── DASHBOARDS.md               # Dashboard documentation
    └── MULTI_ACCOUNT_SETUP.md      # Multi-account setup guide
```

---

## AWS Account Structure

### Account 1: Development & Test (Non-Production)
- **Development Environment**: `dev`
  - Region: `us-east-1`
  - Purpose: Active development, feature testing
  - Cost: ~$500-1,000/month

- **Test Environment**: `test`
  - Region: `us-east-1`
  - Purpose: QA testing, staging
  - Cost: ~$500-1,000/month

### Account 2: Integration & Production
- **Integration Environment**: `integration`
  - Region: `us-east-1`
  - Purpose: Pre-production testing, integration testing
  - Cost: ~$2,000-4,000/month

- **Production Environment**: `production`
  - **US East (us-east-1)**: Primary region
  - **US West (us-west-2)**: Secondary region (disaster recovery)
  - Purpose: Live production traffic
  - Cost: ~$13,500-24,200/month (as per architecture docs)

---

## Prerequisites

1. **Terraform**: >= 1.5.0
2. **AWS CLI**: >= 2.0
3. **AWS Accounts**: 2 separate AWS accounts
4. **AWS IAM Roles**: Cross-account access roles configured
5. **S3 Bucket**: For Terraform remote state (per account)
6. **DynamoDB Table**: For state locking (per account)

---

## Quick Start

### Option A: Local Testing (Recommended First)

Test infrastructure locally with LocalStack before deploying to AWS:

```bash
# Setup local testing environment
./scripts/setup-local-testing.sh

# Or use Make commands
make localstack-start

# Validate configuration
make validate

# Test with LocalStack
make plan-local
make apply-local

# Clean up
make destroy-local
make localstack-stop
```

**See [TESTING.md](./TESTING.md) for detailed local testing guide.**

### Option B: Deploy to AWS

### 1. Setup Remote State Backend

```bash
# Create S3 bucket and DynamoDB table for remote state
./scripts/setup-remote-state.sh <account-id> <environment>
```

### 2. Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example environments/dev/terraform.tfvars

# Edit with your values
vim environments/dev/terraform.tfvars
```

### 3. Initialize Terraform

```bash
cd environments/dev
terraform init -backend-config=backend.tfvars
```

### 4. Plan and Apply

```bash
terraform plan
terraform apply
```

---

## Multi-Account Setup

### Account 1: Dev/Test Account

```bash
# Switch to dev environment
cd environments/dev
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

### Account 2: Integration/Prod Account

```bash
# Switch to integration environment
cd environments/integration
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply

# Deploy to production US East
cd environments/production/us-east-1
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply

# Deploy to production US West
cd environments/production/us-west-2
terraform init -backend-config=backend.tfvars
terraform plan
terraform apply
```

---

## Features

- ✅ Multi-account support (Dev/Test, Integration/Prod)
- ✅ Multi-region support (Production: US-East, US-West)
- ✅ Infrastructure as Code (Terraform)
- ✅ Environment isolation
- ✅ Remote state management (S3 + DynamoDB)
- ✅ State locking (DynamoDB)
- ✅ Modular architecture (reusable modules)
- ✅ CloudWatch Dashboards for KPIs
- ✅ Automated monitoring and alerting
- ✅ Cost optimization built-in (Spot instances, reserved capacity)
- ✅ Security best practices (IAM roles, encryption, WAF)

---

## Environments

### Development
- **Purpose**: Active development
- **Scale**: 10-50 containers, minimal resources
- **Cost**: ~$500-1,000/month
- **Features**: Full feature set, relaxed limits

### Test
- **Purpose**: QA and staging
- **Scale**: 20-100 containers
- **Cost**: ~$500-1,000/month
- **Features**: Production-like but smaller scale

### Integration
- **Purpose**: Pre-production testing
- **Scale**: 50-200 containers
- **Cost**: ~$2,000-4,000/month
- **Features**: Production-like environment

### Production
- **Purpose**: Live production traffic (100K concurrent users)
- **Scale**: 80-750 containers, full scale
- **Cost**: ~$13,500-24,200/month
- **Regions**: US-East (primary), US-West (DR)
- **Features**: Full scale, multi-region, high availability

---

## Dashboards

### Infrastructure Dashboards

1. **Compute Dashboard**: ECS, Lambda metrics
2. **Database Dashboard**: DynamoDB, RDS, DAX, Redis, OpenSearch
3. **Networking Dashboard**: API Gateway, ALB, CloudFront
4. **Cost Dashboard**: Daily spend, cost per service

### Customer Experience Dashboards

1. **API Performance**: Latency, throughput, error rates
2. **User Experience**: Page load times, search performance
3. **Business Metrics**: User counts, equipment views, conversions

See [DASHBOARDS.md](./docs/DASHBOARDS.md) for detailed dashboard documentation.

---

## Security

- **IAM Roles**: Least privilege access
- **Encryption**: At-rest and in-transit
- **Secrets Management**: AWS Secrets Manager
- **Network Isolation**: VPC with private subnets
- **WAF**: DDoS protection, rate limiting
- **Multi-Account**: Isolated production from non-production

---

## Cost Optimization

- **Spot Instances**: 70% of ECS capacity (Dev/Test/Integration)
- **Reserved Instances**: Redis (Production)
- **Auto-Scaling**: Scale down during off-peak hours
- **Caching**: CloudFront, DAX, Redis
- **Serverless**: Lambda, Aurora Serverless v2, OpenSearch Serverless

---

## Deployment Workflow

1. **Development** → Make changes in `dev` environment
2. **Test** → Deploy to `test` environment for QA
3. **Integration** → Deploy to `integration` for pre-production testing
4. **Production** → Deploy to `production` (us-east-1 first, then us-west-2)

---

## Documentation

- **[TESTING.md](./TESTING.md)**: Local testing guide with LocalStack ⭐ **Start Here!**
- [DASHBOARDS.md](./docs/DASHBOARDS.md): Dashboard setup and usage
- [MULTI_ACCOUNT_SETUP.md](./docs/MULTI_ACCOUNT_SETUP.md): Multi-account configuration
- [ENVIRONMENT_SETUP.md](./docs/ENVIRONMENT_SETUP.md): Detailed environment setup (TODO)
- [DEPLOYMENT.md](./docs/DEPLOYMENT.md): Deployment procedures (TODO)

---

## Support

For issues or questions, please refer to the main project documentation or create an issue in the repository.

---

## License

See LICENSE file in the main repository.

