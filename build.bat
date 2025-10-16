@echo off
REM ============================================
REM Docker Image Build and Push Script for Jenkins on Windows
REM ============================================

REM Set Docker Hub credentials from environment variables
SET DOCKER_HUB_USERNAME=%DOCKER_HUB_USERNAME%
SET DOCKER_HUB_PASSWORD=%DOCKER_HUB_PASSWORD%

REM Set branch name or default to 'dev'
IF "%BRANCH_NAME%"=="" SET BRANCH_NAME=dev

REM Check for missing credentials
IF "%DOCKER_HUB_USERNAME%"=="" (
  echo Docker Hub username missing.
  EXIT /B 1
)
IF "%DOCKER_HUB_PASSWORD%"=="" (
  echo Docker Hub password missing.
  EXIT /B 1
)

echo Logging into Docker Hub...
echo %DOCKER_HUB_PASSWORD% | docker login -u %DOCKER_HUB_USERNAME% --password-stdin

REM Build and push based on branch
IF /I "%BRANCH_NAME%"=="dev" (
  docker build -t %DOCKER_HUB_USERNAME%/reactapp3-dev:latest .
  docker push %DOCKER_HUB_USERNAME%/reactapp3-dev:latest
) ELSE IF /I "%BRANCH_NAME%"=="master" (
  docker build -t %DOCKER_HUB_USERNAME%/reactapp3-prod:latest .
  docker push %DOCKER_HUB_USERNAME%/reactapp3-prod:latest
) ELSE (
  echo Branch "%BRANCH_NAME%" is not configured for Docker push.
  EXIT /B 1
)

echo Docker build and push complete!
