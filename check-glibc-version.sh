#!/bin/bash
# Script to check glibc version in the container

echo "=== Checking glibc version ==="
echo ""

# Method 1: Using ldd (shows glibc version)
echo "Method 1: Using ldd --version"
ldd --version 2>&1 | head -1
echo ""

# Method 2: Using rpm query
echo "Method 2: Using rpm -qa | grep glibc"
rpm -qa | grep glibc | sort
echo ""

# Method 3: Using getconf (if available)
echo "Method 3: Using getconf GNU_LIBC_VERSION"
getconf GNU_LIBC_VERSION 2>/dev/null || echo "getconf not available"
echo ""

# Method 4: Check glibc library directly
echo "Method 4: Checking libc.so version"
if [ -f /lib64/libc.so.6 ]; then
    /lib64/libc.so.6 2>&1 | head -1
elif [ -f /lib/libc.so.6 ]; then
    /lib/libc.so.6 2>&1 | head -1
else
    echo "libc.so.6 not found in standard locations"
fi
echo ""

# Method 5: Using strings on libc
echo "Method 5: Using strings to extract version from libc"
if [ -f /lib64/libc.so.6 ]; then
    strings /lib64/libc.so.6 | grep "GLIBC_" | tail -5
elif [ -f /lib/libc.so.6 ]; then
    strings /lib/libc.so.6 | grep "GLIBC_" | tail -5
fi
