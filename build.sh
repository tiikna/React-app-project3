#!/bin/bash
echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" == "dev" ]; then
  docker build -t mishraankit062/reactapp3-dev:latest .
  docker push mishraankit062/reactapp3-dev:latest
elif [ "$BRANCH" == "master" ]; then
  docker build -t mishraankit062/reactapp3-prod:latest .
  docker push mishraankit062/reactapp3-prod:latest
else
  echo "Branch $BRANCH is not configured for Docker push."
fi
