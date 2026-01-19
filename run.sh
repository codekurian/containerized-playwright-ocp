#!/bin/bash

# Run script for Playwright container

set -e

IMAGE_NAME=${1:-playwright-container:latest}

echo "Running Playwright tests in container..."
docker run --rm \
  -v "$(pwd)/tests:/app/tests" \
  -v "$(pwd)/test-results:/app/test-results" \
  -v "$(pwd)/playwright-report:/app/playwright-report" \
  ${IMAGE_NAME}
