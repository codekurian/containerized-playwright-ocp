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
    
    # Download the file
    # Try with SSL verification first (normal case in Docker)
    # Don't use -f flag initially so we can capture HTTP codes even for errors
    curl_output=$(curl -L -o "$output_file" -s -w "\n%{http_code}" "$url" 2>&1)
    curl_exit=$?
    
    # Extract HTTP code from output (last line)
    http_code_from_curl=$(echo "$curl_output" | tail -n 1 | tr -d '\n\r ')
    
    # Handle different curl exit codes
    if [ $curl_exit -ne 0 ]; then
        case $curl_exit in
            77)
                # SSL certificate error - retry with insecure flag
                echo "  ⚠ SSL certificate issue (code 77), retrying with --insecure flag..."
                curl_output=$(curl -L -k -o "$output_file" -s -w "\n%{http_code}" "$url" 2>&1)
                curl_exit=$?
                http_code_from_curl=$(echo "$curl_output" | tail -n 1 | tr -d '\n\r ')
                ;;
            6|7)
                # Connection errors - retry with insecure flag
                echo "  ⚠ Network connection issue (code $curl_exit), retrying with --insecure flag..."
                curl_output=$(curl -L -k -o "$output_file" -s -w "\n%{http_code}" "$url" 2>&1)
                curl_exit=$?
                http_code_from_curl=$(echo "$curl_output" | tail -n 1 | tr -d '\n\r ')
                ;;
            22)
                # HTTP error (404, 403, etc.) - don't retry, just report
                if [ -n "$http_code_from_curl" ] && [[ "$http_code_from_curl" =~ ^[0-9]{3}$ ]]; then
                    echo "  ✗ HTTP error: $http_code_from_curl"
                else
                    # Try to get HTTP code via HEAD request
                    http_code_from_curl=$(curl -L -I -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | tail -c 3)
                    if [ -n "$http_code_from_curl" ] && [[ "$http_code_from_curl" =~ ^[0-9]{3}$ ]]; then
                        echo "  ✗ HTTP error: $http_code_from_curl"
                    else
                        echo "  ✗ HTTP error (exit code 22)"
                        http_code_from_curl="000"
                    fi
                fi
                ;;
            *)
                echo "  ⚠ curl error (exit code $curl_exit)"
                ;;
        esac
    fi
    
    # Use HTTP code from curl output if available, otherwise try HEAD request
    if [ -n "$http_code_from_curl" ] && [[ "$http_code_from_curl" =~ ^[0-9]{3}$ ]]; then
        http_code="$http_code_from_curl"
    else
        # Fallback: try HEAD request to get HTTP code
        http_code=$(curl -L -I -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | tail -c 3)
        if [ -z "$http_code" ] || ! [[ "$http_code" =~ ^[0-9]{3}$ ]]; then
            # If file was downloaded successfully, assume 200
            if [ $curl_exit -eq 0 ] && [ -f "$output_file" ] && [ -s "$output_file" ]; then
                http_code="200"
            else
                http_code="000"
            fi
        fi
    fi
    
    # Show HTTP code for debugging
    echo "  HTTP Status: $http_code"
    
    # Check if file was downloaded successfully (primary check)
    # First check HTTP status code - if it's not 200, it's likely an error
    if [ "$http_code" != "200" ] && [ "$http_code" != "000" ]; then
        # Non-200 HTTP code - likely an error
        if [ -f "$output_file" ] && [ -s "$output_file" ]; then
            # Check if it's an HTML error page
            if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
                echo "  ✗ HTTP error $http_code: Server returned HTML error page"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTTP $http_code - HTML error page)")
                continue
            else
                # Non-HTML file but non-200 status - might be a redirect or error
                echo "  ✗ HTTP error $http_code: Unexpected response"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTTP $http_code)")
                continue
            fi
        else
            # No file created and non-200 status
            echo "  ✗ HTTP error $http_code: File not found or access denied"
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (HTTP $http_code)")
            continue
        fi
    fi
    
    # HTTP code is 200 or unknown (000) - check if file exists and is valid
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        # File exists and has content - check if it's valid
        size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
        
        # Check if it's an HTML error page (even with 200 status, some servers return HTML)
        if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
            echo "  ✗ Server returned HTML error page instead of RPM"
            rm -f "$output_file"
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (HTML error page, HTTP $http_code)")
            continue
        fi
        
        # Verify it's actually an RPM file
        if file "$output_file" 2>/dev/null | grep -q "RPM\|rpm"; then
            echo "  ✓ Downloaded: $filename ($size bytes) - Verified as RPM"
            SUCCESS=$((SUCCESS + 1))
        elif head -c 4 "$output_file" 2>/dev/null | od -An -tx1 2>/dev/null | grep -q "ed ab ee db"; then
            # RPM magic bytes: ed ab ee db
            echo "  ✓ Downloaded: $filename ($size bytes) - Verified as RPM"
            SUCCESS=$((SUCCESS + 1))
        else
            # File exists and has content, but type verification failed
            # Still count as success if it's a reasonable size (might be valid RPM)
            if [ "$size" -gt 1000 ]; then
                echo "  ✓ Downloaded: $filename ($size bytes) - Warning: File type verification inconclusive"
                SUCCESS=$((SUCCESS + 1))
            else
                echo "  ✗ WARNING: File too small or invalid"
                rm -f "$output_file"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (File too small: $size bytes)")
            fi
        fi
    elif [ $curl_exit -ne 0 ]; then
        # Curl failed - check if it's an HTTP error (exit code 22)
        if [ $curl_exit -eq 22 ]; then
            # HTTP error (404, 403, etc.) - file might contain error page
            if [ -f "$output_file" ]; then
                # Check if it's an HTML error page
                if head -1 "$output_file" 2>/dev/null | grep -q "<html\|<!DOCTYPE"; then
                    echo "  ✗ HTTP error $http_code: Server returned HTML error page"
                    rm -f "$output_file"
                    FAILED=$((FAILED + 1))
                    FAILED_LIST+=("$url (HTTP $http_code - HTML error page)")
                else
                    # Non-HTML file but curl returned 22 - might be a redirect or other issue
                    rm -f "$output_file"
                    FAILED=$((FAILED + 1))
                    FAILED_LIST+=("$url (HTTP $http_code - curl exit 22)")
                fi
            else
                echo "  ✗ HTTP error $http_code: File not found or access denied"
                FAILED=$((FAILED + 1))
                FAILED_LIST+=("$url (HTTP $http_code)")
            fi
        else
            # Other curl errors
            echo "  ✗ WARNING: curl failed with exit code $curl_exit"
            if [ -f "$output_file" ]; then
                rm -f "$output_file"
            fi
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (curl error $curl_exit)")
        fi
    elif [ -f "$output_file" ] && [ ! -s "$output_file" ]; then
        # File exists but is empty
        echo "  ✗ WARNING: File is empty"
        rm -f "$output_file"
        FAILED=$((FAILED + 1))
        FAILED_LIST+=("$url (Empty file)")
    else
        # File doesn't exist
        echo "  ✗ WARNING: File not created after download"
        FAILED=$((FAILED + 1))
        FAILED_LIST+=("$url (File not created, HTTP $http_code)")
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
