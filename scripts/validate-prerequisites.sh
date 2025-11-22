#!/bin/bash

# Script to validate all prerequisites for IAC repository
# This script checks if all required tools are installed

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Prerequisites Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Function to check command
check_command() {
    local cmd=$1
    local name=$2
    local required=${3:-true}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$($cmd --version 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} ${name}: ${version}"
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}✗${NC} ${name}: NOT INSTALLED (Required)"
            ((ERRORS++))
        else
            echo -e "${YELLOW}⚠${NC} ${name}: NOT INSTALLED (Optional)"
            ((WARNINGS++))
        fi
        return 1
    fi
}

echo -e "${BLUE}Required Tools:${NC}"
echo ""

# Required tools
check_command "terraform" "Terraform" true
check_command "docker" "Docker" true
check_command "docker-compose" "Docker Compose" true

echo ""
echo -e "${BLUE}Optional Tools:${NC}"
echo ""

# Optional tools
check_command "aws" "AWS CLI" false
check_command "jq" "jq (JSON parser)" false
check_command "tflint" "TFLint (Terraform linter)" false
check_command "gh" "GitHub CLI" false
check_command "make" "Make" false

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required tools are installed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ ${WARNINGS} optional tool(s) missing${NC}"
    fi
    echo ""
    echo -e "${GREEN}You can now run:${NC}"
    echo -e "  ${YELLOW}make validate${NC}        - Validate Terraform configuration"
    echo -e "  ${YELLOW}make localstack-start${NC} - Start LocalStack for testing"
    exit 0
else
    echo -e "${RED}✗ ${ERRORS} required tool(s) missing${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ ${WARNINGS} optional tool(s) missing${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Installation Instructions:${NC}"
    echo ""
    
    # Terraform
    if ! command -v terraform >/dev/null 2>&1; then
        echo -e "${BLUE}Terraform:${NC}"
        echo "  macOS:  brew install terraform"
        echo "  Linux:  See https://www.terraform.io/downloads"
        echo ""
    fi
    
    # Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${BLUE}Docker:${NC}"
        echo "  macOS:  Install Docker Desktop from https://www.docker.com/products/docker-desktop"
        echo "  Linux:  See https://docs.docker.com/engine/install/"
        echo ""
    fi
    
    # Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo -e "${BLUE}Docker Compose:${NC}"
        echo "  macOS:  Included with Docker Desktop"
        echo "  Linux:  sudo apt-get install docker-compose"
        echo ""
    fi
    
    # Optional tools
    if ! command -v aws >/dev/null 2>&1; then
        echo -e "${YELLOW}AWS CLI (Optional):${NC}"
        echo "  macOS:  brew install awscli"
        echo "  Linux:  See https://aws.amazon.com/cli/"
        echo ""
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${YELLOW}jq (Optional):${NC}"
        echo "  macOS:  brew install jq"
        echo ""
    fi
    
    if ! command -v tflint >/dev/null 2>&1; then
        echo -e "${YELLOW}TFLint (Optional):${NC}"
        echo "  macOS:  brew install tflint"
        echo ""
    fi
    
    exit 1
fi

