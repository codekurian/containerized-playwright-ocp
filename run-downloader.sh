#!/bin/bash

# Script to run the RPM downloader in Docker

# Default values
URLS_FILE="${1:-rpm_urls_minimal.txt}"
OUTPUT_DIR="${2:-./downloads}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if Docker image exists
if ! docker image inspect playwright-chromium:latest >/dev/null 2>&1; then
    echo "Docker image not found. Building..."
    docker build -t playwright-chromium:latest .
fi

echo "Running RPM downloader in Docker..."
echo "URLs file: $URLS_FILE"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Run the downloader in Docker with volume mounts
docker run --rm \
  -v "$(pwd)/$OUTPUT_DIR:/app/downloads" \
  -v "$(pwd)/$URLS_FILE:/app/$URLS_FILE" \
  playwright-chromium:latest \
  /app/download-rpms.sh "/app/$URLS_FILE" /app/downloads

echo ""
echo "Downloaded files are available in: $OUTPUT_DIR"
