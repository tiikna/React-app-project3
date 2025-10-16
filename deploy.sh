#!/bin/bash
set -e

# Default to dev
BRANCH_NAME="${BRANCH_NAME:-dev}"

if [ "$BRANCH_NAME" = "master" ]; then
  export DOCKER_IMAGE="mishraankit062/reactapp3-prod:latest"
else
  export DOCKER_IMAGE="mishraankit062/reactapp3-dev:latest"
fi

docker-compose down
docker-compose up -d --build
