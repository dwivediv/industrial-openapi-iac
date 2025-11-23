#!/bin/bash

# Docker Complete Cleanup Script for macOS
# This script removes all Docker-related files, directories, and configurations

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Docker Complete Cleanup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running as root for some operations
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo -e "${YELLOW}Step 1: Stopping Docker processes...${NC}"
# Kill any running Docker processes
pkill -f Docker 2>/dev/null || true
pkill -f com.docker 2>/dev/null || true
echo -e "${GREEN}✓ Docker processes stopped${NC}"
echo ""

echo -e "${YELLOW}Step 2: Removing Docker configuration...${NC}"
rm -rf ~/.docker
echo -e "${GREEN}✓ Removed ~/.docker${NC}"
echo ""

echo -e "${YELLOW}Step 3: Removing Docker Library directories (may require password)...${NC}"
# These may require special permissions
rm -rf ~/Library/Application\ Scripts/com.docker.helper 2>/dev/null || echo -e "${YELLOW}⚠ Some files require special permissions${NC}"
rm -rf ~/Library/Containers/com.docker.helper 2>/dev/null || echo -e "${YELLOW}⚠ Some files require special permissions${NC}"
rm -rf ~/Library/Containers/com.docker.docker 2>/dev/null || echo -e "${YELLOW}⚠ Some files require special permissions${NC}"
rm -rf ~/Library/Group\ Containers/group.com.docker 2>/dev/null || echo -e "${YELLOW}⚠ Some files require special permissions${NC}"
echo -e "${GREEN}✓ Removed Docker Library directories${NC}"
echo ""

echo -e "${YELLOW}Step 4: Removing Docker symlinks from /usr/local/bin (requires sudo)...${NC}"
$SUDO rm -f /usr/local/bin/docker 2>/dev/null || true
$SUDO rm -f /usr/local/bin/docker-compose 2>/dev/null || true
$SUDO rm -f /usr/local/bin/docker-credential-desktop 2>/dev/null || true
$SUDO rm -f /usr/local/bin/docker-credential-osxkeychain 2>/dev/null || true
$SUDO rm -f /usr/local/bin/docker-machine 2>/dev/null || true
echo -e "${GREEN}✓ Removed Docker symlinks${NC}"
echo ""

echo -e "${YELLOW}Step 5: Removing Docker CLI plugins...${NC}"
$SUDO rm -rf /usr/local/cli-plugins 2>/dev/null || true
echo -e "${GREEN}✓ Removed CLI plugins${NC}"
echo ""

echo -e "${YELLOW}Step 6: Removing Docker Desktop application support...${NC}"
rm -rf ~/Library/Application\ Support/Docker\ Desktop 2>/dev/null || true
echo -e "${GREEN}✓ Removed Docker Desktop application support${NC}"
echo ""

echo -e "${YELLOW}Step 7: Removing Docker preferences...${NC}"
rm -rf ~/Library/Preferences/com.docker.docker.plist 2>/dev/null || true
rm -rf ~/Library/Preferences/com.docker.helper.plist 2>/dev/null || true
echo -e "${GREEN}✓ Removed Docker preferences${NC}"
echo ""

echo -e "${YELLOW}Step 8: Removing Docker saved application state...${NC}"
rm -rf ~/Library/Saved\ Application\ State/com.docker.docker.savedState 2>/dev/null || true
echo -e "${GREEN}✓ Removed Docker saved state${NC}"
echo ""

echo -e "${YELLOW}Step 9: Removing Docker caches...${NC}"
rm -rf ~/Library/Caches/com.docker.docker 2>/dev/null || true
rm -rf ~/Library/Caches/com.docker.helper 2>/dev/null || true
echo -e "${GREEN}✓ Removed Docker caches${NC}"
echo ""

echo -e "${YELLOW}Step 10: Removing Docker.app from Applications (if exists)...${NC}"
if [ -d "/Applications/Docker.app" ]; then
    $SUDO rm -rf /Applications/Docker.app
    echo -e "${GREEN}✓ Removed Docker.app${NC}"
else
    echo -e "${GREEN}✓ Docker.app not found${NC}"
fi
echo ""

echo -e "${YELLOW}Step 11: Uninstalling Docker via Homebrew (if installed)...${NC}"
export PATH="/opt/homebrew/bin:$PATH"
if command -v brew >/dev/null 2>&1; then
    brew uninstall --cask docker 2>/dev/null && echo -e "${GREEN}✓ Removed Docker via Homebrew${NC}" || echo -e "${GREEN}✓ Docker not installed via Homebrew${NC}"
else
    echo -e "${YELLOW}⚠ Homebrew not found${NC}"
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Docker cleanup completed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Some protected files in ~/Library/Containers may still exist."
echo -e "${YELLOW}If you see permission errors, you may need to:${NC}"
echo -e "  1. Grant Full Disk Access to Terminal in System Preferences"
echo -e "  2. Or manually remove: ~/Library/Containers/com.docker.*"
echo ""

