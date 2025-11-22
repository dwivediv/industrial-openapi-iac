#!/bin/bash

# Setup script for local testing with LocalStack
# This script sets up the local testing environment

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up local testing environment...${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed.${NC}" >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo -e "${RED}Docker Compose is required but not installed.${NC}" >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed.${NC}" >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed.${NC}" >&2; exit 1; }

echo -e "${GREEN}All prerequisites met!${NC}"

# Create LocalStack environment file
if [ ! -f .localstack-env ]; then
    echo -e "${YELLOW}Creating .localstack-env file...${NC}"
    cp .localstack-env.example .localstack-env
    echo -e "${GREEN}Created .localstack-env (update if needed)${NC}"
else
    echo -e "${GREEN}.localstack-env already exists${NC}"
fi

# Start LocalStack
echo -e "${YELLOW}Starting LocalStack...${NC}"
docker-compose up -d localstack

# Wait for LocalStack to be ready
echo -e "${YELLOW}Waiting for LocalStack to be ready...${NC}"
timeout=60
elapsed=0
while ! curl -s http://localhost:4566/_localstack/health | grep -q "\"s3\": \"available\""; do
    if [ $elapsed -ge $timeout ]; then
        echo -e "${RED}LocalStack failed to start within ${timeout} seconds${NC}"
        exit 1
    fi
    sleep 2
    elapsed=$((elapsed + 2))
    echo -e "${YELLOW}Waiting... (${elapsed}s/${timeout}s)${NC}"
done

echo -e "${GREEN}LocalStack is ready!${NC}"

# Configure AWS CLI for LocalStack
echo -e "${YELLOW}Configuring AWS CLI for LocalStack...${NC}"
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Setup S3 backend
echo -e "${YELLOW}Setting up S3 backend...${NC}"
aws --endpoint-url=http://localhost:4566 s3 mb s3://terraform-state-local 2>/dev/null || echo "Bucket already exists"

# Setup DynamoDB table for state locking
echo -e "${YELLOW}Setting up DynamoDB state lock table...${NC}"
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST 2>/dev/null || echo "Table already exists"

echo -e "${GREEN}Local testing environment setup complete!${NC}"
echo -e "${GREEN}You can now run:${NC}"
echo -e "  ${YELLOW}make validate${NC}        - Validate Terraform configuration"
echo -e "  ${YELLOW}make plan-local${NC}      - Plan with LocalStack"
echo -e "  ${YELLOW}make apply-local${NC}     - Apply to LocalStack"
echo -e "  ${YELLOW}make localstack-logs${NC} - View LocalStack logs"
echo -e "  ${YELLOW}make localstack-health${NC} - Check LocalStack health"

