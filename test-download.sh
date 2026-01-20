#!/bin/bash
# Quick test script to verify download functionality

echo "Testing download script with first URL from rpm_urls_minimal.txt..."

# Get first URL
FIRST_URL=$(head -1 rpm_urls_minimal.txt 2>/dev/null)

if [ -z "$FIRST_URL" ]; then
    echo "ERROR: Could not read rpm_urls_minimal.txt"
    exit 1
fi

echo "Testing URL: $FIRST_URL"
echo ""

# Test with curl directly first
echo "=== Direct curl test ==="
TEST_FILE="/tmp/test_download.rpm"
http_code=$(curl -L -w "%{http_code}" -o "$TEST_FILE" -s "$FIRST_URL" 2>&1 | tail -c 3)
curl_exit=$?

echo "Curl exit code: $curl_exit"
echo "HTTP code: $http_code"

if [ -f "$TEST_FILE" ]; then
    size=$(stat -f%z "$TEST_FILE" 2>/dev/null || stat -c%s "$TEST_FILE" 2>/dev/null || echo "0")
    echo "File size: $size bytes"
    
    # Check file type
    if command -v file &> /dev/null; then
        echo "File type: $(file "$TEST_FILE")"
    fi
    
    # Check if it's HTML
    if head -1 "$TEST_FILE" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
        echo "⚠ WARNING: File appears to be HTML (error page)"
        head -5 "$TEST_FILE"
    else
        echo "✓ File appears to be binary (likely RPM)"
    fi
    
    rm -f "$TEST_FILE"
else
    echo "✗ File was not created"
fi

echo ""
echo "=== Testing download script ==="
mkdir -p /tmp/test_downloads
./download-rpms.sh rpm_urls_minimal.txt /tmp/test_downloads | head -20
