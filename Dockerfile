# Use Red Hat UBI 8.10 base image for OpenShift compatibility
FROM registry.access.redhat.com/ubi8:8.10

# Set working directory
WORKDIR /app

# Install OpenJDK 21 and required system dependencies
RUN dnf install -y java-21-openjdk java-21-openjdk-devel curl gcc-c++ make python3 wget unzip && \
    dnf clean all

# Download Chromium dependencies as RPMs and store them separately
# These are minimal low-level binaries required for Chromium headless mode only
# Step 1: Create directory to store downloaded RPMs
RUN mkdir -p /opt/rpms/playwright-deps

# Step 2: Download RPMs directly from documented endpoints using curl commands
# Minimal set of 47 RPM URLs (down from 217) - only essential packages for headless Chromium
# Copy rpm_urls_minimal.txt to save URLs for reference
COPY rpm_urls_minimal.txt /tmp/rpm_urls.txt

RUN cd /opt/rpms/playwright-deps && \
    echo "=== Downloading minimal RPMs for headless Chromium ===" && \
    echo "Total packages to download: 47 (minimal set for headless mode)" && \
    # Save repository URLs for reference
    cp /tmp/rpm_urls.txt /opt/rpms/repository-urls.txt && \
    echo "Repository URLs saved to /opt/rpms/repository-urls.txt" && \
    # Download minimal RPMs using direct curl commands (47 packages for headless Chromium only)
    curl -L -f -s -o "at-spi2-atk-2.26.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/at-spi2-atk-2.26.2-1.el8.aarch64.rpm" || echo "Failed: at-spi2-atk-2.26.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "atk-2.28.1-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/atk-2.28.1-1.el8.aarch64.rpm" || echo "Failed: atk-2.28.1-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "cairo-1.15.12-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-1.15.12-6.el8.aarch64.rpm" || echo "Failed: cairo-1.15.12-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "cairo-gobject-1.15.12-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-gobject-1.15.12-6.el8.aarch64.rpm" || echo "Failed: cairo-gobject-1.15.12-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "graphite2-1.3.10-10.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/graphite2-1.3.10-10.el8.aarch64.rpm" || echo "Failed: graphite2-1.3.10-10.el8.aarch64.rpm" && \
    curl -L -f -s -o "harfbuzz-1.7.5-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/harfbuzz-1.7.5-4.el8.aarch64.rpm" || echo "Failed: harfbuzz-1.7.5-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "libX11-1.6.8-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-1.6.8-9.el8_10.aarch64.rpm" || echo "Failed: libX11-1.6.8-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libX11-common-1.6.8-9.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-common-1.6.8-9.el8_10.noarch.rpm" || echo "Failed: libX11-common-1.6.8-9.el8_10.noarch.rpm" && \
    curl -L -f -s -o "libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" || echo "Failed: libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libXScrnSaver-1.2.3-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXScrnSaver-1.2.3-1.el8.aarch64.rpm" || echo "Failed: libXScrnSaver-1.2.3-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXau-1.0.9-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXau-1.0.9-3.el8.aarch64.rpm" || echo "Failed: libXau-1.0.9-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXcomposite-0.4.4-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcomposite-0.4.4-14.el8.aarch64.rpm" || echo "Failed: libXcomposite-0.4.4-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXdamage-1.1.4-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXdamage-1.1.4-14.el8.aarch64.rpm" || echo "Failed: libXdamage-1.1.4-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXext-1.3.4-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXext-1.3.4-1.el8.aarch64.rpm" || echo "Failed: libXext-1.3.4-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXfixes-5.0.3-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXfixes-5.0.3-7.el8.aarch64.rpm" || echo "Failed: libXfixes-5.0.3-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXrandr-1.5.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrandr-1.5.2-1.el8.aarch64.rpm" || echo "Failed: libXrandr-1.5.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libdrm-2.4.115-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdrm-2.4.115-2.el8.aarch64.rpm" || echo "Failed: libdrm-2.4.115-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-egl-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-egl-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-egl-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-glx-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-glx-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-glx-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" || echo "Failed: libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-client-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-client-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-client-1.21.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-egl-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-egl-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-egl-1.21.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libwebp-1.0.0-11.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwebp-1.0.0-11.el8_10.aarch64.rpm" || echo "Failed: libwebp-1.0.0-11.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libxcb-1.13.1-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxcb-1.13.1-1.el8.aarch64.rpm" || echo "Failed: libxcb-1.13.1-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libxkbcommon-0.9.1-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxkbcommon-0.9.1-1.el8.aarch64.rpm" || echo "Failed: libxkbcommon-0.9.1-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libxshmfence-1.3-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxshmfence-1.3-2.el8.aarch64.rpm" || echo "Failed: libxshmfence-1.3-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "mesa-libEGL-23.1.4-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libEGL-23.1.4-4.el8_10.aarch64.rpm" || echo "Failed: mesa-libEGL-23.1.4-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "mesa-libGL-23.1.4-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libGL-23.1.4-4.el8_10.aarch64.rpm" || echo "Failed: mesa-libGL-23.1.4-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "mesa-libgbm-23.1.4-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libgbm-23.1.4-4.el8_10.aarch64.rpm" || echo "Failed: mesa-libgbm-23.1.4-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "mesa-libglapi-23.1.4-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libglapi-23.1.4-4.el8_10.aarch64.rpm" || echo "Failed: mesa-libglapi-23.1.4-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nspr-4.36.0-2.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nspr-4.36.0-2.el8_10.aarch64.rpm" || echo "Failed: nspr-4.36.0-2.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nss-3.112.0-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-3.112.0-4.el8_10.aarch64.rpm" || echo "Failed: nss-3.112.0-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nss-softokn-3.112.0-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-softokn-3.112.0-4.el8_10.aarch64.rpm" || echo "Failed: nss-softokn-3.112.0-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nss-softokn-freebl-3.112.0-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-softokn-freebl-3.112.0-4.el8_10.aarch64.rpm" || echo "Failed: nss-softokn-freebl-3.112.0-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nss-sysinit-3.112.0-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-sysinit-3.112.0-4.el8_10.aarch64.rpm" || echo "Failed: nss-sysinit-3.112.0-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "nss-util-3.112.0-4.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-util-3.112.0-4.el8_10.aarch64.rpm" || echo "Failed: nss-util-3.112.0-4.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "pango-1.42.4-8.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/p/pango-1.42.4-8.el8.aarch64.rpm" || echo "Failed: pango-1.42.4-8.el8.aarch64.rpm" && \
    curl -L -f -s -o "pixman-0.38.4-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/p/pixman-0.38.4-4.el8.aarch64.rpm" || echo "Failed: pixman-0.38.4-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "dejavu-fonts-common-2.35-7.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-fonts-common-2.35-7.el8.noarch.rpm" || echo "Failed: dejavu-fonts-common-2.35-7.el8.noarch.rpm" && \
    curl -L -f -s -o "dejavu-sans-fonts-2.35-7.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-sans-fonts-2.35-7.el8.noarch.rpm" || echo "Failed: dejavu-sans-fonts-2.35-7.el8.noarch.rpm" && \
    curl -L -f -s -o "fontconfig-2.13.1-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/fontconfig-2.13.1-4.el8.aarch64.rpm" || echo "Failed: fontconfig-2.13.1-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "freetype-2.9.1-10.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/freetype-2.9.1-10.el8_10.aarch64.rpm" || echo "Failed: freetype-2.9.1-10.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libgcc-8.5.0-28.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgcc-8.5.0-28.el8_10.aarch64.rpm" || echo "Failed: libgcc-8.5.0-28.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libicu-60.3-2.el8_1.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libicu-60.3-2.el8_1.aarch64.rpm" || echo "Failed: libicu-60.3-2.el8_1.aarch64.rpm" && \
    curl -L -f -s -o "libpng-1.6.34-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpng-1.6.34-9.el8_10.aarch64.rpm" || echo "Failed: libpng-1.6.34-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libstdc++-8.5.0-28.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libstdc++-8.5.0-28.el8_10.aarch64.rpm" || echo "Failed: libstdc++-8.5.0-28.el8_10.aarch64.rpm" && \
        echo "=== Downloaded RPM packages with versions ===" && \
    for rpm in *.rpm; do \
        if [ -f "$rpm" ]; then \
            PKG_INFO=$(rpm -qp --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}' "$rpm" 2>/dev/null || echo "$rpm"); \
            echo "$PKG_INFO: $(ls -lh "$rpm" | awk '{print $5}')"; \
        fi; \
    done | sort > /opt/rpms/package-versions.txt && \
    cat /opt/rpms/package-versions.txt && \
    echo "=== Total packages downloaded: $(ls -1 *.rpm 2>/dev/null | wc -l) ===" && \
    rm -f /tmp/rpm_urls.txt

# Step 3: Install packages from downloaded RPMs (downloaded from direct endpoints)
# Installing from local RPMs ensures we use the exact versions we downloaded
RUN cd /opt/rpms/playwright-deps && \
    echo "=== Installing browser dependencies from downloaded RPMs ===" && \
    if [ -n "$(ls -A *.rpm 2>/dev/null)" ]; then \
        echo "Installing $(ls -1 *.rpm 2>/dev/null | wc -l) RPM packages..." && \
        dnf localinstall -y --skip-broken *.rpm 2>&1 | tail -20 && \
        echo "=== Verification: Installed package versions ===" && \
        rpm -qa | grep -E "libX11|libXcomposite|mesa-libgbm|nss|gtk3|pango|harfbuzz|libicu|libXScrnSaver|libdrm" | sort; \
    else \
        echo "No RPMs found, falling back to repository installation" && \
        dnf install -y \
            libXScrnSaver libX11 libXcomposite libXcursor libXdamage libXext libXi libXrandr libXtst libX11-xcb \
            libdrm libxkbcommon libxshmfence \
            mesa-libgbm mesa-libEGL mesa-libGL \
            nss alsa-lib atk cups-libs gtk3 pango harfbuzz \
            libicu libxslt libevent libwebp libjpeg-turbo enchant libsecret libffi \
        || echo "Some packages may not be available"; \
    fi && \
    dnf clean all

# Note: RPMs are stored in /opt/rpms/playwright-deps/ for reference
# - RPM files: /opt/rpms/playwright-deps/*.rpm
# - Package versions: /opt/rpms/package-versions.txt
# - Repository URLs: /opt/rpms/repository-urls.txt
# You can inspect them with: docker run --rm <image> ls -lh /opt/rpms/playwright-deps/

# Install Node.js 20.x
# Using NodeSource repository for Node.js 20.x
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf install -y nodejs && \
    dnf clean all

# Install specific npm version 10.8.2 if needed
# npm comes with Node.js, but we can upgrade/downgrade if necessary
RUN npm install -g npm@10.8.2 || true

# Verify Node.js and npm versions
RUN node --version && npm --version

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies (without installing Playwright browsers)
RUN npm install

# Download Chromium directly using curl (version 1194, matching Playwright 1.56.1)
# This is the exact Chromium build that Playwright expects
RUN mkdir -p /opt/playwright-chromium && \
    echo "=== Downloading Chromium via curl ===" && \
    curl -L -f -s -o /tmp/chromium-linux-arm64.zip \
        "https://cdn.playwright.dev/dbazure/download/playwright/builds/chromium/1194/chromium-linux-arm64.zip" && \
    echo "Chromium zip downloaded, extracting..." && \
    unzip -q /tmp/chromium-linux-arm64.zip -d /opt/playwright-chromium/ && \
    rm -f /tmp/chromium-linux-arm64.zip && \
    CHROMIUM_BIN=$(find /opt/playwright-chromium -name "chrome" -type f | head -1) && \
    if [ -z "$CHROMIUM_BIN" ]; then \
        echo "Error: Chromium binary not found after extraction"; \
        find /opt/playwright-chromium -type f | head -10; \
        exit 1; \
    fi && \
    chmod +x "$CHROMIUM_BIN" && \
    ln -sf "$CHROMIUM_BIN" /opt/playwright-chromium/chrome && \
    echo "Chromium installed at /opt/playwright-chromium/chrome" && \
    /opt/playwright-chromium/chrome --version || echo "Version check failed, but binary exists"

# Note: Only Chromium is installed. Firefox and WebKit are not needed.
# System dependencies for Chromium are already installed via the minimal RPM packages above.

# Copy application files
COPY . .

# Make download scripts executable
RUN chmod +x download-rpms.sh 2>/dev/null || echo "download-rpms.sh not found, will be available after COPY"

# Set environment variables
ENV NODE_ENV=production
# Set Chromium executable path for Playwright (headless mode)
ENV PLAYWRIGHT_CHROMIUM_PATH=/opt/playwright-chromium/chrome

# Default command
CMD ["npm", "test"]
