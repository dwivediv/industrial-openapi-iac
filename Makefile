.PHONY: help localstack-start localstack-stop localstack-logs test-local validate plan-local apply-local destroy-local clean

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RED    := $(shell tput -Txterm setaf 1)
RESET  := $(shell tput -Txterm sgr0)

help: ## Show this help message
	@echo '${YELLOW}Usage:${RESET}'
	@echo '  make ${GREEN}<target>${RESET}'
	@echo ''
	@echo '${YELLOW}LocalStack Targets:${RESET}'
	@echo '  ${GREEN}localstack-start${RESET}        Start LocalStack container'
	@echo '  ${GREEN}localstack-stop${RESET}         Stop LocalStack container'
	@echo '  ${GREEN}localstack-logs${RESET}         View LocalStack logs'
	@echo '  ${GREEN}localstack-health${RESET}       Check LocalStack health'
	@echo ''
	@echo '${YELLOW}Testing Targets:${RESET}'
	@echo '  ${GREEN}test-local${RESET}              Run all local tests'
	@echo '  ${GREEN}validate${RESET}                Validate Terraform configuration'
	@echo '  ${GREEN}fmt${RESET}                     Format Terraform files'
	@echo '  ${GREEN}lint${RESET}                    Lint Terraform files'
	@echo ''
	@echo '${YELLOW}Terraform Targets (LocalStack):${RESET}'
	@echo '  ${GREEN}plan-local${RESET}              Plan Terraform with LocalStack backend'
	@echo '  ${GREEN}apply-local${RESET}             Apply Terraform to LocalStack'
	@echo '  ${GREEN}destroy-local${RESET}           Destroy resources in LocalStack'
	@echo ''
	@echo '${YELLOW}Cleanup Targets:${RESET}'
	@echo '  ${GREEN}clean${RESET}                   Clean local test data'

# LocalStack Management
localstack-start: ## Start LocalStack container
	@echo "${GREEN}Starting LocalStack...${RESET}"
	docker-compose up -d localstack
	@echo "${GREEN}Waiting for LocalStack to be ready...${RESET}"
	@timeout 60 bash -c 'until curl -s http://localhost:4566/_localstack/health | grep -q "\"s3\": \"available\""; do sleep 2; done' || true
	@echo "${GREEN}LocalStack is ready!${RESET}"
	@make setup-localstack-backend

localstack-stop: ## Stop LocalStack container
	@echo "${YELLOW}Stopping LocalStack...${RESET}"
	docker-compose down

localstack-logs: ## View LocalStack logs
	docker-compose logs -f localstack

localstack-health: ## Check LocalStack health
	@curl -s http://localhost:4566/_localstack/health | jq '.'

# Setup LocalStack backend
setup-localstack-backend:
	@echo "${GREEN}Setting up LocalStack S3 backend...${RESET}"
	@aws --endpoint-url=http://localhost:4566 s3 mb s3://terraform-state-local || true
	@aws --endpoint-url=http://localhost:4566 dynamodb create-table \
		--table-name terraform-state-lock \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--billing-mode PAY_PER_REQUEST 2>/dev/null || true
	@echo "${GREEN}LocalStack backend ready!${RESET}"

# Terraform Validation
validate: ## Validate Terraform configuration
	@echo "${GREEN}Validating Terraform configuration...${RESET}"
	@cd environments/dev && terraform init -backend=false && terraform validate
	@cd environments/test && terraform init -backend=false && terraform validate
	@cd environments/integration && terraform init -backend=false && terraform validate
	@echo "${GREEN}All configurations validated!${RESET}"

fmt: ## Format Terraform files
	@echo "${GREEN}Formatting Terraform files...${RESET}"
	terraform fmt -recursive
	@echo "${GREEN}Formatting complete!${RESET}"

lint: ## Lint Terraform files
	@echo "${GREEN}Linting Terraform files...${RESET}"
	@which tflint > /dev/null || (echo "${RED}tflint not installed. Install with: brew install tflint${RESET}" && exit 1)
	tflint --recursive
	@echo "${GREEN}Linting complete!${RESET}"

# Local Testing with LocalStack
plan-local: ## Plan Terraform with LocalStack
	@echo "${GREEN}Planning Terraform with LocalStack...${RESET}"
	@export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
	@cd environments/dev && \
		terraform init -backend-config=backend.tfvars.local && \
		terraform plan -var-file=terraform.tfvars.local

apply-local: ## Apply Terraform to LocalStack
	@echo "${GREEN}Applying Terraform to LocalStack...${RESET}"
	@export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
	@cd environments/dev && \
		terraform init -backend-config=backend.tfvars.local && \
		terraform apply -var-file=terraform.tfvars.local -auto-approve

destroy-local: ## Destroy resources in LocalStack
	@echo "${YELLOW}Destroying resources in LocalStack...${RESET}"
	@export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
	@cd environments/dev && \
		terraform init -backend-config=backend.tfvars.local && \
		terraform destroy -var-file=terraform.tfvars.local -auto-approve

test-local: validate fmt lint ## Run all local tests
	@echo "${GREEN}All local tests passed!${RESET}"

# Cleanup
clean: ## Clean local test data
	@echo "${YELLOW}Cleaning local test data...${RESET}"
	rm -rf .terraform environments/*/.terraform localstack-data moto-data
	@echo "${GREEN}Cleanup complete!${RESET}"

