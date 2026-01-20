# RPM File Downloader - Batch/Shell Script

A batch script (Windows) and shell script (Linux/Unix) to download RPM files from URLs listed in a file. Designed to run in Docker and save files to a mounted volume on the local machine.

## Features

- Downloads files from URLs listed in a text file
- Progress tracking with file size display
- Warnings for failed downloads
- Skips already downloaded files
- Can run in Docker with volume mounting
- Works on both Windows (.cmd) and Linux/Unix (.sh)

## Usage

### Option 1: Run Locally (Windows)

```cmd
REM Run with defaults (reads rpm_urls_minimal.txt, saves to downloads)
download-rpms.cmd

REM Custom file and output directory
download-rpms.cmd rpm_urls_minimal.txt C:\path\to\output
```

### Option 2: Run Locally (Linux/Unix)

```bash
# Run with defaults (reads rpm_urls_minimal.txt, saves to ./downloads)
./download-rpms.sh

# Custom file and output directory
./download-rpms.sh rpm_urls_minimal.txt /path/to/output
```

### Option 3: Run in Docker

```bash
# Build the Docker image first (if not already built)
docker build -t playwright-chromium:latest .

# Run the downloader with volume mount to save files locally
docker run --rm \
  -v "$(pwd)/downloads:/app/downloads" \
  -v "$(pwd)/rpm_urls_minimal.txt:/app/rpm_urls_minimal.txt" \
  playwright-chromium:latest \
  /app/download-rpms.sh /app/rpm_urls_minimal.txt /app/downloads
```

### Option 4: Using the Helper Script

```bash
# Run downloader in Docker (automatically mounts volumes)
./run-downloader.sh

# Or with custom parameters
./run-downloader.sh rpm_urls_minimal.txt /path/to/downloads
```

## Arguments

1. **URLs file** (optional): Path to file containing URLs, one per line. Default: `rpm_urls_minimal.txt`
2. **Output directory** (optional): Directory to save downloaded files. Default: `downloads` (Windows) or `./downloads` (Linux/Unix)

## Output

- Progress messages showing `[current/total] Downloading: filename ... ✓ Downloaded (size)`
- Warnings for failed downloads: `✗ WARNING: Failed to download filename - reason`
- Summary at the end showing successful and failed download counts
- Failed downloads list with reasons

## Example Output

```
=== RPM File Downloader ===
URLs file: rpm_urls_minimal.txt
Output directory: ./downloads

Found 47 URLs to download

[1/47] Downloading: at-spi2-atk-2.26.2-1.el8.aarch64.rpm ... ✓ Downloaded (89088 bytes)
[2/47] Downloading: atk-2.28.1-1.el8.aarch64.rpm ... ✓ Downloaded (277504 bytes)
[3/47] Downloading: cairo-1.15.12-6.el8.aarch64.rpm ... ✗ WARNING: Failed to download - Download error
[4/47] SKIP (exists): libX11-1.6.8-9.el8_10.aarch64.rpm (604160 bytes)
...

=== Download Summary ===
Successful: 45
Failed: 2

=== Failed Downloads ===
  ✗ https://cdn-ubi.redhat.com/.../cairo-1.15.12-6.el8.aarch64.rpm (Download error)
  ✗ https://cdn-ubi.redhat.com/.../libX11-1.6.8-9.el8_10.aarch64.rpm (File not created)
```

## Requirements

- `curl` (already installed in Docker container, available on Windows 10+ and most Linux systems)
- `bash` (for .sh script, already available in Docker container)
- `cmd.exe` (for .cmd script, built into Windows)

## Notes

- Files are downloaded sequentially (one at a time)
- Already downloaded files are skipped automatically
- Empty lines and lines starting with `#` are ignored in the URLs file
- Exit code is 1 if any downloads failed, 0 if all succeeded
- The script uses `curl` which is available in the Docker container and modern Windows/Linux systems
