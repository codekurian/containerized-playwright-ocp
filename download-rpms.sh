#!/bin/bash
# RPM File Downloader - Shell Script (Linux/Unix alternative)
# Downloads RPM files from URLs listed in a file
# Usage: download-rpms.sh [urls-file] [output-dir]

# Default values
URLS_FILE="${1:-rpm_urls_minimal.txt}"
OUTPUT_DIR="${2:-./downloads}"

echo "=== RPM File Downloader ==="
echo "URLs file: $URLS_FILE"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Check if URLs file exists
if [ ! -f "$URLS_FILE" ]; then
    echo "ERROR: File not found: $URLS_FILE"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Count total URLs
TOTAL=$(grep -v '^[[:space:]]*$' "$URLS_FILE" | grep -v '^#' | wc -l)
echo "Found $TOTAL URLs to download"
echo ""

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "ERROR: curl is not installed or not in PATH"
    exit 1
fi

# Test network connectivity
echo "Testing network connectivity..."
if curl -s --max-time 5 -o /dev/null https://www.google.com 2>/dev/null; then
    echo "✓ Network connectivity OK"
else
    echo "⚠ WARNING: Network connectivity test failed - downloads may fail"
fi
echo ""

# Initialize counters
SUCCESS=0
FAILED=0
CURRENT=0
FAILED_LIST=()

# Download each URL
while IFS= read -r url || [ -n "$url" ]; do
    # Skip empty lines and comments
    url=$(echo "$url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -z "$url" ] || [ "${url#\#}" != "$url" ]; then
        continue
    fi
    
    CURRENT=$((CURRENT + 1))
    
    # Extract filename from URL
    filename=$(basename "$url")
    output_file="$OUTPUT_DIR/$filename"
    
    # Check if file already exists
    if [ -f "$output_file" ]; then
        size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
        echo "[$CURRENT/$TOTAL] SKIP (exists): $filename ($size bytes)"
        SUCCESS=$((SUCCESS + 1))
        continue
    fi
    
    # Download the file
    echo "[$CURRENT/$TOTAL] Downloading: $filename"
    echo "  URL: $url"
    
    # Download and capture HTTP status code
    # Use a temp file to capture HTTP code separately
    temp_http_code="/tmp/curl_http_$$"
    
    # Try with SSL verification first
    curl -L -w "%{http_code}" -o "$output_file" -s "$url" > "$temp_http_code" 2>&1
    curl_exit=$?
    
    # If SSL certificate error (77), try with insecure flag
    if [ $curl_exit -eq 77 ]; then
        echo "  ⚠ SSL certificate issue, retrying with --insecure flag..."
        curl -L -k -w "%{http_code}" -o "$output_file" -s "$url" > "$temp_http_code" 2>&1
        curl_exit=$?
    fi
    
    # Read HTTP code from temp file (last 3 characters)
    if [ -f "$temp_http_code" ]; then
        http_code=$(tail -c 3 "$temp_http_code" 2>/dev/null | tr -d '\n')
        rm -f "$temp_http_code"
    else
        http_code="000"
    fi
    
    # Verify we got a 3-digit HTTP code (200-599)
    if [ -z "$http_code" ] || [ ${#http_code} -ne 3 ] || ! [[ "$http_code" =~ ^[0-9]{3}$ ]]; then
        # Fallback: try HEAD request to get HTTP code
        http_code=$(curl -L -I -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | tail -c 3)
        if [ -z "$http_code" ] || ! [[ "$http_code" =~ ^[0-9]{3}$ ]]; then
            # If file exists and has content, assume 200
            if [ -f "$output_file" ] && [ -s "$output_file" ]; then
                http_code="200"
            else
                http_code="000"
            fi
        fi
    fi
    
    # Show HTTP code for debugging
    echo "  HTTP Status: $http_code"
    
    # Check curl exit code
    if [ $curl_exit -ne 0 ]; then
        echo "  ✗ WARNING: curl failed with exit code $curl_exit"
        if [ -f "$output_file" ]; then
            # Check if output file contains an error message (HTML error page)
            if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
                echo "  ✗ Server returned HTML error page"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTML error page)")
            else
                echo "  ✗ Download error (check network/URL)"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (curl error $curl_exit)")
            fi
        else
            echo "  ✗ Download failed - file not created"
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (curl error $curl_exit)")
        fi
        continue
    fi
    
    # Check HTTP status code
    if [ -z "$http_code" ] || [ "$http_code" != "200" ]; then
        echo "  ✗ WARNING: HTTP status code: $http_code"
        if [ -f "$output_file" ]; then
            size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
            echo "  File size: $size bytes"
            # Check if it's an HTML error page
            if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
                echo "  ✗ Server returned HTML error page instead of RPM"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTTP $http_code - HTML error)")
            else
                # Non-200 but file exists - might be a redirect or error
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTTP $http_code)")
            fi
        else
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (HTTP $http_code - no file)")
        fi
        continue
    fi
    
    # Check if file was downloaded successfully
    if [ -f "$output_file" ]; then
        if [ ! -s "$output_file" ]; then
            echo "  ✗ WARNING: File is empty"
            rm -f "$output_file"
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (Empty file)")
        else
            size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
            # Verify it's actually an RPM file (RPM files start with specific magic bytes)
            if file "$output_file" 2>/dev/null | grep -q "RPM\|rpm"; then
                echo "  ✓ Downloaded: $filename ($size bytes) - Verified as RPM"
                SUCCESS=$((SUCCESS + 1))
            elif head -c 4 "$output_file" 2>/dev/null | od -An -tx1 | grep -q "ed ab ee db"; then
                # RPM magic bytes: ed ab ee db
                echo "  ✓ Downloaded: $filename ($size bytes) - Verified as RPM"
                SUCCESS=$((SUCCESS + 1))
            else
                # Check if it's HTML (error page)
                if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
                    echo "  ✗ WARNING: Server returned HTML instead of RPM file"
                    rm -f "$output_file"
                    FAILED=$((FAILED + 1))
                    FAILED_LIST+=("$url (HTML response instead of RPM)")
                else
                    echo "  ✓ Downloaded: $filename ($size bytes) - Warning: File type verification failed"
                    SUCCESS=$((SUCCESS + 1))
                fi
            fi
        fi
    else
        echo "  ✗ WARNING: File not created after download"
        FAILED=$((FAILED + 1))
        FAILED_LIST+=("$url (File not created)")
    fi
done < "$URLS_FILE"

# Print summary
echo ""
echo "=== Download Summary ==="
echo "Successful: $SUCCESS"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "=== Failed Downloads ==="
    for failed_url in "${FAILED_LIST[@]}"; do
        echo "  ✗ $failed_url"
    done
fi

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
