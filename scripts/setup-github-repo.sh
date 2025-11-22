#!/bin/bash

# Script to create GitHub repository and push code
# Usage: ./scripts/setup-github-repo.sh [github-username] [repo-name]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
GITHUB_USERNAME="${1:-dwivediv}"
REPO_NAME="${2:-industrial-openapi-iac}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GitHub Repository Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Repository: ${NC}${REPO_NAME}"
echo -e "${YELLOW}Username: ${NC}${GITHUB_USERNAME}"
echo ""

# Check if gh CLI is installed
if command -v gh >/dev/null 2>&1; then
    echo -e "${GREEN}✓ GitHub CLI (gh) is installed${NC}"
    
    # Check if logged in
    if gh auth status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ GitHub CLI is authenticated${NC}"
        echo ""
        
        # Create repository
        echo -e "${YELLOW}Creating repository on GitHub...${NC}"
        gh repo create "$REPO_NAME" \
            --public \
            --description "Infrastructure as Code (IAC) for Industrial Equipment Marketplace" \
            --source=. \
            --remote=origin \
            --push || {
                echo -e "${YELLOW}Repository might already exist. Continuing...${NC}"
            }
        
        echo -e "${GREEN}✓ Repository created${NC}"
        echo ""
        
        # Push all branches
        echo -e "${YELLOW}Pushing all branches...${NC}"
        git push -u origin main
        git push -u origin dev 2>/dev/null || true
        git push -u origin stage 2>/dev/null || true
        
        echo -e "${GREEN}✓ All branches pushed${NC}"
        echo ""
        echo -e "${GREEN}Repository URL:${NC}"
        echo -e "  https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
        
    else
        echo -e "${RED}✗ GitHub CLI is not authenticated${NC}"
        echo -e "${YELLOW}Please run: ${NC}gh auth login"
        exit 1
    fi
else
    echo -e "${YELLOW}GitHub CLI (gh) is not installed${NC}"
    echo -e "${YELLOW}Installing via Homebrew...${NC}"
    
    if command -v brew >/dev/null 2>&1; then
        read -p "Install GitHub CLI? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew install gh
            gh auth login
            # Re-run this script
            exec "$0" "$@"
        fi
    fi
    
    echo -e "${YELLOW}Alternative: Create repository manually on GitHub.com${NC}"
    echo -e "${YELLOW}Then run: ${NC}./scripts/push-to-github.sh ${GITHUB_USERNAME} ${REPO_NAME}"
fi

