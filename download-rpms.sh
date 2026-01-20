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
    echo -n "[$CURRENT/$TOTAL] Downloading: $filename ... "
    
    if curl -L -f -s -o "$output_file" "$url"; then
        if [ -f "$output_file" ] && [ -s "$output_file" ]; then
            size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
            echo "✓ Downloaded ($size bytes)"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "✗ WARNING: File is empty"
            rm -f "$output_file"
            FAILED=$((FAILED + 1))
            FAILED_LIST+=("$url (Empty file)")
        fi
    else
        echo "✗ WARNING: Download failed"
        rm -f "$output_file"
        FAILED=$((FAILED + 1))
        FAILED_LIST+=("$url (Download error)")
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
