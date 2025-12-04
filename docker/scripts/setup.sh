#!/bin/bash
echo "Setting up environment..."
cp .env.example .env
docker-compose -f docker/compose/docker-compose.yml up -d --build
echo "Setup complete!"
