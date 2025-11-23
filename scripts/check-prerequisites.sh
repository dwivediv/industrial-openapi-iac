#!/bin/bash

# Comprehensive Prerequisites Check Script
# This script checks all required tools and provides installation instructions
# Location: industrial-openapi-iac/scripts/check-prerequisites.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MISSING_TOOLS=()
WARNINGS=()

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Prerequisites Check for Local Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function to check command and provide installation instructions
check_tool() {
    local tool=$1
    local install_cmd=$2
    local description=$3
    
    if command -v "$tool" >/dev/null 2>&1; then
        local version
        version=$($tool --version 2>/dev/null | head -n1 || echo "installed")
        echo -e "${GREEN}✓${NC} $description: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $description: NOT INSTALLED"
        echo -e "   ${YELLOW}Install with:${NC} $install_cmd"
        MISSING_TOOLS+=("$tool")
        return 1
    fi
}

# Check required tools
echo -e "${BLUE}Checking Required Tools...${NC}"
check_tool "docker" "brew install --cask docker" "Docker" || true
# Check for docker-compose (standalone) or docker compose (plugin)
if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
    if command -v docker-compose >/dev/null 2>&1; then
        VERSION=$(docker-compose --version 2>/dev/null | head -n1 || echo "installed")
    else
        VERSION=$(docker compose version 2>/dev/null | head -n1 || echo "installed")
    fi
    echo -e "${GREEN}✓${NC} Docker Compose: $VERSION"
else
    echo -e "${RED}✗${NC} Docker Compose: NOT INSTALLED"
    echo -e "   ${YELLOW}Install with:${NC} brew install docker-compose (or use Docker Desktop which includes it)"
    MISSING_TOOLS+=("docker-compose")
fi
check_tool "terraform" "brew install terraform" "Terraform (>= 1.5.0)" || true
check_tool "aws" "brew install awscli" "AWS CLI (>= 2.0)" || true
check_tool "curl" "brew install curl" "curl" || true
check_tool "jq" "brew install jq" "jq" || true
check_tool "make" "xcode-select --install" "Make" || true

echo ""

# Check optional tools
echo -e "${BLUE}Checking Optional Tools...${NC}"
if command -v tflint >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} TFLint: $(tflint --version | head -n1)"
else
    echo -e "${YELLOW}⚠${NC} TFLint: NOT INSTALLED (optional)"
    echo -e "   ${YELLOW}Install with:${NC} brew install tflint"
fi

echo ""

# Check Docker daemon
echo -e "${BLUE}Checking Docker Daemon...${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is not running"
    echo -e "   ${YELLOW}Start Docker Desktop or run:${NC} open -a Docker"
    WARNINGS+=("Docker daemon not running")
fi

echo ""

# Check Terraform version
if command -v terraform >/dev/null 2>&1; then
    echo -e "${BLUE}Checking Terraform Version...${NC}"
    TF_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    if [ -n "$TF_VERSION" ]; then
        REQUIRED_VERSION="1.5.0"
        if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$TF_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
            echo -e "${RED}✗${NC} Terraform version $TF_VERSION is below required $REQUIRED_VERSION"
            echo -e "   ${YELLOW}Upgrade with:${NC} brew upgrade terraform"
            WARNINGS+=("Terraform version too old")
        else
            echo -e "${GREEN}✓${NC} Terraform version $TF_VERSION meets requirement (>= $REQUIRED_VERSION)"
        fi
    fi
    echo ""
fi

# Check AWS CLI version
if command -v aws >/dev/null 2>&1; then
    echo -e "${BLUE}Checking AWS CLI Version...${NC}"
    AWS_VERSION=$(aws --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    if [ -n "$AWS_VERSION" ]; then
        REQUIRED_VERSION="2.0.0"
        if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$AWS_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
            echo -e "${YELLOW}⚠${NC} AWS CLI version $AWS_VERSION may be below recommended $REQUIRED_VERSION"
            echo -e "   ${YELLOW}Upgrade with:${NC} brew upgrade awscli"
        else
            echo -e "${GREEN}✓${NC} AWS CLI version $AWS_VERSION meets requirement (>= $REQUIRED_VERSION)"
        fi
    fi
    echo ""
fi

# Check for timeout command (macOS compatibility)
echo -e "${BLUE}Checking macOS Compatibility...${NC}"
if command -v timeout >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} timeout command available"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}⚠${NC} timeout command not found (macOS)"
    echo -e "   ${YELLOW}Install with:${NC} brew install coreutils"
    echo -e "   ${YELLOW}Note:${NC} Scripts will use alternative method if timeout is unavailable"
    WARNINGS+=("timeout command not available")
fi
echo ""

# Check required configuration files
echo -e "${BLUE}Checking Configuration Files...${NC}"
echo -e "${YELLOW}Checking in: $REPO_ROOT${NC}"

if [ -f "$REPO_ROOT/.localstack-env.example" ]; then
    echo -e "${GREEN}✓${NC} .localstack-env.example exists"
else
    echo -e "${RED}✗${NC} .localstack-env.example is missing"
    echo -e "   ${YELLOW}Expected at:${NC} $REPO_ROOT/.localstack-env.example"
    MISSING_TOOLS+=("config files")
fi

if [ -f "$REPO_ROOT/environments/dev/backend.tfvars.local" ]; then
    echo -e "${GREEN}✓${NC} environments/dev/backend.tfvars.local exists"
else
    echo -e "${RED}✗${NC} environments/dev/backend.tfvars.local is missing"
    echo -e "   ${YELLOW}Expected at:${NC} $REPO_ROOT/environments/dev/backend.tfvars.local"
    MISSING_TOOLS+=("config files")
fi

if [ -f "$REPO_ROOT/environments/dev/terraform.tfvars.local" ]; then
    echo -e "${GREEN}✓${NC} environments/dev/terraform.tfvars.local exists"
else
    echo -e "${RED}✗${NC} environments/dev/terraform.tfvars.local is missing"
    echo -e "   ${YELLOW}Expected at:${NC} $REPO_ROOT/environments/dev/terraform.tfvars.local"
    MISSING_TOOLS+=("config files")
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
if [ ${#MISSING_TOOLS[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All prerequisites are met!${NC}"
    echo -e "${GREEN}You can now run: ./scripts/setup-local-testing.sh${NC}"
    exit 0
elif [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ Prerequisites met with warnings${NC}"
    for warning in "${WARNINGS[@]}"; do
        echo -e "   ${YELLOW}-${NC} $warning"
    done
    echo ""
    echo -e "${GREEN}You can proceed, but some features may not work correctly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Missing required prerequisites${NC}"
    echo ""
    echo -e "${YELLOW}Please install the missing tools and run this script again.${NC}"
    echo ""
    echo -e "${BLUE}Quick Install (macOS):${NC}"
    echo -e "  brew install --cask docker"
    echo -e "  brew install terraform awscli jq"
    echo -e "  brew install coreutils  # for timeout command (optional)"
    exit 1
fi
