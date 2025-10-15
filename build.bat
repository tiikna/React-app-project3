#!/bin/bash
# Hardcoded credentials (replace with your actual Docker Hub username and password/token)
DOCKER_HUB_USERNAME="mishraankit062"
DOCKER_HUB_PASSWORD="Ankit@1212"
BRANCH_NAME=${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}
IMAGE_NAME="mishraankit062/reactapp3"
if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
  echo "Docker Hub credentials are missing."
  exit 1
fi
echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
if [ "$BRANCH_NAME" = "dev" ]; then
  docker build -t ${IMAGE_NAME}-dev:latest .
  docker push ${IMAGE_NAME}-dev:latest
elif [ "$BRANCH_NAME" = "master" ]; then
  docker build -t ${IMAGE_NAME}-prod:latest .
  docker push ${IMAGE_NAME}-prod:latest
else
  echo "Branch $BRANCH_NAME is not configured for Docker push."
fi
