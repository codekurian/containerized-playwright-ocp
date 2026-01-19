#!/bin/bash

# Build script for Playwright container

set -e

echo "Building Playwright container..."
docker build -t playwright-container:latest .

echo "Build completed successfully!"
echo ""
echo "To run tests:"
echo "  docker run --rm playwright-container:latest"
echo ""
echo "Or use docker-compose:"
echo "  docker-compose up"
