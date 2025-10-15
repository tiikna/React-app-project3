#!/bin/bash
# Hardcoded credentials (replace with your actual Docker Hub username and password/token)
#DOCKER_HUB_USERNAME="mishraankit062"
#DOCKER_HUB_PASSWORD="Ankit@1212"
#BRANCH_NAME=${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}
#IMAGE_NAME="mishraankit062/reactapp3"
#if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
#  echo "Docker Hub credentials are missing."
#  exit 1
#fi
#echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
#if [ "$BRANCH_NAME" = "dev" ]; then
#  docker build -t ${IMAGE_NAME}-dev:latest .
#  docker push ${IMAGE_NAME}-dev:latest
#elif [ "$BRANCH_NAME" = "master" ]; then
#  docker build -t ${IMAGE_NAME}-prod:latest .
#  docker push ${IMAGE_NAME}-prod:latest
#else
#  echo "Branch $BRANCH_NAME is not configured for Docker push."
#fi

@echo off
REM Hardcoded credentials (better to get from env to avoid hardcoding!)
set DOCKER_HUB_USERNAME=mishraankit062
set DOCKER_HUB_PASSWORD=Ankit@1212
SET BRANCH_NAME=%BRANCH_NAME%
IF "%BRANCH_NAME%"=="" SET BRANCH_NAME=dev

IF "%DOCKER_HUB_USERNAME%"=="" (
  echo Docker Hub username missing.
  exit /b 1
)
IF "%DOCKER_HUB_PASSWORD%"=="" (
  echo Docker Hub password missing.
  exit /b 1
)

echo Logging into Docker Hub...
echo %DOCKER_HUB_PASSWORD% | docker login -u %DOCKER_HUB_USERNAME% --password-stdin

IF /I "%BRANCH_NAME%"=="dev" (
  docker build -t %DOCKER_HUB_USERNAME%/reactapp3-dev:latest .
  docker push %DOCKER_HUB_USERNAME%/reactapp3-dev:latest
) ELSE IF /I "%BRANCH_NAME%"=="master" (
  docker build -t %DOCKER_HUB_USERNAME%/reactapp3-prod:latest .
  docker push %DOCKER_HUB_USERNAME%/reactapp3-prod:latest
) ELSE (
  echo Branch %BRANCH_NAME% is not configured for Docker push.
)
