@echo off
REM RPM File Downloader - Windows Batch Script
REM Downloads RPM files from URLs listed in a file
REM Usage: download-rpms.cmd [urls-file] [output-dir]

setlocal enabledelayedexpansion

REM Default values
set "URLS_FILE=%~1"
if "%URLS_FILE%"=="" set "URLS_FILE=rpm_urls_minimal.txt"
set "OUTPUT_DIR=%~2"
if "%OUTPUT_DIR%"=="" set "OUTPUT_DIR=downloads"

echo === RPM File Downloader ===
echo URLs file: %URLS_FILE%
echo Output directory: %OUTPUT_DIR%
echo.

REM Check if URLs file exists
if not exist "%URLS_FILE%" (
    echo ERROR: File not found: %URLS_FILE%
    exit /b 1
)

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Count total URLs
set /a TOTAL=0
for /f "usebackq delims=" %%i in ("%URLS_FILE%") do (
    set "line=%%i"
    set "line=!line: =!"
    if not "!line!"=="" (
        if not "!line:~0,1!"=="#" (
            set /a TOTAL+=1
        )
    )
)

echo Found !TOTAL! URLs to download
echo.

REM Initialize counters
set /a SUCCESS=0
set /a FAILED=0
set /a CURRENT=0
set "FAILED_LIST="

REM Download each URL
for /f "usebackq delims=" %%i in ("%URLS_FILE%") do (
    set "url=%%i"
    set "url=!url: =!"
    
    REM Skip empty lines and comments
    if not "!url!"=="" (
        if not "!url:~0,1!"=="#" (
            set /a CURRENT+=1
            
            REM Extract filename from URL
            for %%j in ("!url!") do set "filename=%%~nxj"
            
            REM Check if file already exists
            if exist "%OUTPUT_DIR%\!filename!" (
                echo [!CURRENT!/!TOTAL!] SKIP ^(exists^): !filename!
                set /a SUCCESS+=1
            ) else (
                REM Download the file
                echo [!CURRENT!/!TOTAL!] Downloading: !filename! ...
                
                REM Try using curl (available in Docker/Windows 10+)
                curl -L -f -s -o "%OUTPUT_DIR%\!filename!" "!url!" >nul 2>&1
                
                if !errorlevel! equ 0 (
                    REM Check if file was downloaded (size > 0)
                    if exist "%OUTPUT_DIR%\!filename!" (
                        for %%k in ("%OUTPUT_DIR%\!filename!") do set "filesize=%%~zk"
                        if !filesize! gtr 0 (
                            echo [!CURRENT!/!TOTAL!] ^✓ Downloaded: !filename! ^(!filesize! bytes^)
                            set /a SUCCESS+=1
                        ) else (
                            echo [!CURRENT!/!TOTAL!] ✗ WARNING: Failed to download !filename! - File is empty
                            del "%OUTPUT_DIR%\!filename!" >nul 2>&1
                            set /a FAILED+=1
                            set "FAILED_LIST=!FAILED_LIST!!url! (Empty file)^n"
                        )
                    ) else (
                        echo [!CURRENT!/!TOTAL!] ✗ WARNING: Failed to download !filename! - File not created
                        set /a FAILED+=1
                        set "FAILED_LIST=!FAILED_LIST!!url! (File not created)^n"
                    )
                ) else (
                    echo [!CURRENT!/!TOTAL!] ✗ WARNING: Failed to download !filename! - Download error
                    set /a FAILED+=1
                    set "FAILED_LIST=!FAILED_LIST!!url! (Download error)^n"
                )
            )
        )
    )
)

REM Print summary
echo.
echo === Download Summary ===
echo Successful: !SUCCESS!
echo Failed: !FAILED!
echo.

if !FAILED! gtr 0 (
    echo === Failed Downloads ===
    echo !FAILED_LIST!
)

if !FAILED! gtr 0 (
    exit /b 1
) else (
    exit /b 0
)
