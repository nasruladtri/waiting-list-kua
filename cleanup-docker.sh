#!/bin/bash

# Cleanup script untuk Docker resources
# Usage: ./cleanup-docker.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== KUA Waiting List - Docker Cleanup Script ===${NC}"
echo ""

# Stop and remove containers
echo -e "${GREEN}Stopping containers...${NC}"
docker-compose down

# Remove images
read -p "Do you want to remove Docker images? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Removing images...${NC}"
    docker rmi kua-waiting-list:latest 2>/dev/null || true
    docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
fi

# Remove volumes
read -p "Do you want to remove volumes (this will delete emulator data)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Warning: This will delete all emulator data!${NC}"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Removing volumes...${NC}"
        docker volume rm kua-waiting-list_firebase-data 2>/dev/null || true
    fi
fi

# Clean up unused resources
echo -e "${GREEN}Cleaning up unused resources...${NC}"
docker system prune -f

echo ""
echo -e "${GREEN}=== Cleanup Complete ===${NC}"
