#!/bin/bash

# Build script untuk Docker image KUA Waiting List
# Usage: ./build.sh [version]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="kua-waiting-list"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_USERNAME="${DOCKER_USERNAME:-yourusername}"

# Get version from argument or use 'latest'
VERSION="${1:-latest}"

echo -e "${GREEN}=== KUA Waiting List - Docker Build Script ===${NC}"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found. Copying from .env.example${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env file with your configuration${NC}"
fi

# Build Docker image
echo -e "${GREEN}Building Docker image...${NC}"
docker build -f docker/emulators.Dockerfile -t ${IMAGE_NAME}:${VERSION} .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully: ${IMAGE_NAME}:${VERSION}${NC}"
else
    echo -e "${RED}✗ Failed to build Docker image${NC}"
    exit 1
fi

# Tag image for registry
FULL_IMAGE_NAME="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo -e "${GREEN}Tagging image as ${FULL_IMAGE_NAME}${NC}"
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}

# Ask if user wants to push to registry
read -p "Do you want to push to Docker registry? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Pushing to Docker registry...${NC}"
    docker push ${FULL_IMAGE_NAME}
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Image pushed successfully${NC}"
        echo -e "${GREEN}Image: ${FULL_IMAGE_NAME}${NC}"
    else
        echo -e "${RED}✗ Failed to push image${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo -e "Local image: ${IMAGE_NAME}:${VERSION}"
echo -e "Registry image: ${FULL_IMAGE_NAME}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update docker-stack.yml with image: ${FULL_IMAGE_NAME}"
echo "2. Deploy to Portainer"
echo "3. Set environment variables in Portainer"
