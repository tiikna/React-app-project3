#!/bin/bash
set -e
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME}"
DOCKER_HUB_PASSWORD="${DOCKER_HUB_PASSWORD}"

# Set branch name or default to 'dev'
BRANCH_NAME="${BRANCH_NAME:-dev}"

# Check for missing credentials
if [ -z "$DOCKER_HUB_USERNAME" ]; then
  echo "Docker Hub username missing."
  exit 1
fi

if [ -z "$DOCKER_HUB_PASSWORD" ]; then
  echo "Docker Hub password missing."
  exit 1
fi

echo "Logging into Docker Hub..."
echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin

# Build and push based on branch
if [ "$BRANCH_NAME" = "dev" ]; then
  docker build -t "$DOCKER_HUB_USERNAME/reactapp3-dev:latest" .
  docker push "$DOCKER_HUB_USERNAME/reactapp3-dev:latest"
elif [ "$BRANCH_NAME" = "main" ]; then
  docker build -t "$DOCKER_HUB_USERNAME/reactapp3-prod:latest" .
  docker push "$DOCKER_HUB_USERNAME/reactapp3-prod:latest"
else
  echo "Branch \"$BRANCH_NAME\" is not configured for Docker push."
  exit 1
fi
echo "Docker build and push complete!"
