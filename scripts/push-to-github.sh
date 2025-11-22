#!/bin/bash

# Script to push all branches to GitHub
# Usage: ./scripts/push-to-github.sh [github-username] [repo-name]

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
REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Push to GitHub Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Repository: ${NC}${REPO_NAME}"
echo -e "${YELLOW}Username: ${NC}${GITHUB_USERNAME}"
echo -e "${YELLOW}Remote URL: ${NC}${REMOTE_URL}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if remote already exists
if git remote | grep -q "^origin$"; then
    EXISTING_URL=$(git remote get-url origin)
    echo -e "${YELLOW}Remote 'origin' already exists: ${NC}${EXISTING_URL}"
    
    if [ "$EXISTING_URL" != "$REMOTE_URL" ]; then
        read -p "Do you want to update the remote URL to ${REMOTE_URL}? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote set-url origin "$REMOTE_URL"
            echo -e "${GREEN}Remote URL updated${NC}"
        else
            echo -e "${YELLOW}Using existing remote URL${NC}"
            REMOTE_URL="$EXISTING_URL"
        fi
    else
        echo -e "${GREEN}Remote URL matches${NC}"
    fi
else
    # Add remote
    echo -e "${YELLOW}Adding remote 'origin'...${NC}"
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}Remote added${NC}"
fi

# Verify remote connection
echo -e "${YELLOW}Verifying GitHub connection...${NC}"
if git ls-remote --heads origin > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Connection verified${NC}"
else
    echo -e "${RED}✗ Error: Cannot connect to GitHub${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo -e "  1. Repository exists at: ${REMOTE_URL}"
    echo -e "  2. You have push access"
    echo -e "  3. Your GitHub credentials are configured"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}Current branch: ${NC}${CURRENT_BRANCH}"
echo ""

# Function to push branch
push_branch() {
    local branch=$1
    local set_upstream=$2
    
    echo -e "${BLUE}Pushing branch: ${NC}${branch}"
    
    if git show-ref --verify --quiet refs/heads/$branch; then
        if [ "$set_upstream" = "true" ]; then
            git push -u origin "$branch"
        else
            git push origin "$branch"
        fi
        echo -e "${GREEN}✓ Branch '${branch}' pushed successfully${NC}"
        echo ""
        return 0
    else
        echo -e "${YELLOW}⚠ Branch '${branch}' does not exist locally${NC}"
        echo ""
        return 1
    fi
}

# Push all branches
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Pushing Branches${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Push main branch (with upstream)
if [ "$CURRENT_BRANCH" = "main" ]; then
    push_branch "main" "true"
else
    git checkout main 2>/dev/null || echo -e "${YELLOW}Already on main${NC}"
    push_branch "main" "true"
    git checkout "$CURRENT_BRANCH" 2>/dev/null || true
fi

# Push dev branch
if git show-ref --verify --quiet refs/heads/dev; then
    push_branch "dev" "true"
fi

# Push stage branch
if git show-ref --verify --quiet refs/heads/stage; then
    push_branch "stage" "true"
fi

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}✓ All branches pushed to GitHub${NC}"
echo ""
echo -e "${YELLOW}Repository URL:${NC}"
echo -e "  ${REMOTE_URL}"
echo ""
echo -e "${YELLOW}Branches:${NC}"
git branch -r --list "origin/*" | sed 's/origin\//  - /'
echo ""
echo -e "${GREEN}Done!${NC}"
echo ""

