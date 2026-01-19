# Use Red Hat UBI 8.10 base image for OpenShift compatibility
FROM registry.access.redhat.com/ubi8:8.10

# Set working directory
WORKDIR /app

# Install OpenJDK 21 and required system dependencies
RUN dnf install -y java-21-openjdk java-21-openjdk-devel curl gcc-c++ make python3 wget unzip && \
    dnf clean all

# Download Chromium dependencies as RPMs and store them separately
# These are low-level binaries required for Chromium, Firefox, and WebKit to run
# Step 1: Create directory to store downloaded RPMs
RUN mkdir -p /opt/rpms/playwright-deps

# Step 2: Download RPMs directly from documented endpoints using curl commands
# All 217 RPM URLs are embedded directly in the Dockerfile for explicit control
# Copy rpm_urls.txt to save URLs for reference
COPY rpm_urls.txt /tmp/rpm_urls.txt

RUN cd /opt/rpms/playwright-deps && \
    echo "=== Downloading RPMs directly from documented repository URLs ===" && \
    echo "Total packages to download: 217" && \
    # Save repository URLs for reference
    cp /tmp/rpm_urls.txt /opt/rpms/repository-urls.txt && \
    echo "Repository URLs saved to /opt/rpms/repository-urls.txt" && \
    # Download all RPMs using direct curl commands
    curl -L -f -s -o "abattis-cantarell-fonts-0.0.25-6.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/abattis-cantarell-fonts-0.0.25-6.el8.noarch.rpm" || echo "Failed: abattis-cantarell-fonts-0.0.25-6.el8.noarch.rpm" && \
    curl -L -f -s -o "adwaita-cursor-theme-3.28.0-3.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/adwaita-cursor-theme-3.28.0-3.el8.noarch.rpm" || echo "Failed: adwaita-cursor-theme-3.28.0-3.el8.noarch.rpm" && \
    curl -L -f -s -o "adwaita-icon-theme-3.28.0-3.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/adwaita-icon-theme-3.28.0-3.el8.noarch.rpm" || echo "Failed: adwaita-icon-theme-3.28.0-3.el8.noarch.rpm" && \
    curl -L -f -s -o "alsa-lib-1.2.10-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/alsa-lib-1.2.10-2.el8.aarch64.rpm" || echo "Failed: alsa-lib-1.2.10-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "at-spi2-atk-2.26.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/at-spi2-atk-2.26.2-1.el8.aarch64.rpm" || echo "Failed: at-spi2-atk-2.26.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "at-spi2-core-2.28.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/at-spi2-core-2.28.0-1.el8.aarch64.rpm" || echo "Failed: at-spi2-core-2.28.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "atk-2.28.1-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/atk-2.28.1-1.el8.aarch64.rpm" || echo "Failed: atk-2.28.1-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "cairo-1.15.12-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-1.15.12-6.el8.aarch64.rpm" || echo "Failed: cairo-1.15.12-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "cairo-gobject-1.15.12-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-gobject-1.15.12-6.el8.aarch64.rpm" || echo "Failed: cairo-gobject-1.15.12-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "colord-libs-1.4.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/colord-libs-1.4.2-1.el8.aarch64.rpm" || echo "Failed: colord-libs-1.4.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "dconf-0.28.0-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/d/dconf-0.28.0-4.el8.aarch64.rpm" || echo "Failed: dconf-0.28.0-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "enchant-1.6.0-21.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/e/enchant-1.6.0-21.el8.aarch64.rpm" || echo "Failed: enchant-1.6.0-21.el8.aarch64.rpm" && \
    curl -L -f -s -o "fribidi-1.0.4-9.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/f/fribidi-1.0.4-9.el8.aarch64.rpm" || echo "Failed: fribidi-1.0.4-9.el8.aarch64.rpm" && \
    curl -L -f -s -o "gdk-pixbuf2-modules-2.36.12-7.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gdk-pixbuf2-modules-2.36.12-7.el8_10.aarch64.rpm" || echo "Failed: gdk-pixbuf2-modules-2.36.12-7.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "graphite2-1.3.10-10.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/graphite2-1.3.10-10.el8.aarch64.rpm" || echo "Failed: graphite2-1.3.10-10.el8.aarch64.rpm" && \
    curl -L -f -s -o "gtk-update-icon-cache-3.22.30-12.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gtk-update-icon-cache-3.22.30-12.el8_10.aarch64.rpm" || echo "Failed: gtk-update-icon-cache-3.22.30-12.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "gtk3-3.22.30-12.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gtk3-3.22.30-12.el8_10.aarch64.rpm" || echo "Failed: gtk3-3.22.30-12.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "harfbuzz-1.7.5-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/harfbuzz-1.7.5-4.el8.aarch64.rpm" || echo "Failed: harfbuzz-1.7.5-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "hicolor-icon-theme-0.17-2.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hicolor-icon-theme-0.17-2.el8.noarch.rpm" || echo "Failed: hicolor-icon-theme-0.17-2.el8.noarch.rpm" && \
    curl -L -f -s -o "hunspell-1.6.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hunspell-1.6.2-1.el8.aarch64.rpm" || echo "Failed: hunspell-1.6.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "hunspell-en-US-0.20140811.1-12.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hunspell-en-US-0.20140811.1-12.el8.noarch.rpm" || echo "Failed: hunspell-en-US-0.20140811.1-12.el8.noarch.rpm" && \
    curl -L -f -s -o "jasper-libs-2.0.14-6.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/j/jasper-libs-2.0.14-6.el8_10.aarch64.rpm" || echo "Failed: jasper-libs-2.0.14-6.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "jbigkit-libs-2.1-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/j/jbigkit-libs-2.1-14.el8.aarch64.rpm" || echo "Failed: jbigkit-libs-2.1-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "lcms2-2.9-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/lcms2-2.9-2.el8.aarch64.rpm" || echo "Failed: lcms2-2.9-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libX11-1.6.8-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-1.6.8-9.el8_10.aarch64.rpm" || echo "Failed: libX11-1.6.8-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libX11-common-1.6.8-9.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-common-1.6.8-9.el8_10.noarch.rpm" || echo "Failed: libX11-common-1.6.8-9.el8_10.noarch.rpm" && \
    curl -L -f -s -o "libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" || echo "Failed: libX11-xcb-1.6.8-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libXScrnSaver-1.2.3-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXScrnSaver-1.2.3-1.el8.aarch64.rpm" || echo "Failed: libXScrnSaver-1.2.3-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXau-1.0.9-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXau-1.0.9-3.el8.aarch64.rpm" || echo "Failed: libXau-1.0.9-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXcomposite-0.4.4-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcomposite-0.4.4-14.el8.aarch64.rpm" || echo "Failed: libXcomposite-0.4.4-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXcursor-1.1.15-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcursor-1.1.15-3.el8.aarch64.rpm" || echo "Failed: libXcursor-1.1.15-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXdamage-1.1.4-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXdamage-1.1.4-14.el8.aarch64.rpm" || echo "Failed: libXdamage-1.1.4-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXext-1.3.4-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXext-1.3.4-1.el8.aarch64.rpm" || echo "Failed: libXext-1.3.4-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXfixes-5.0.3-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXfixes-5.0.3-7.el8.aarch64.rpm" || echo "Failed: libXfixes-5.0.3-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXft-2.3.3-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXft-2.3.3-1.el8.aarch64.rpm" || echo "Failed: libXft-2.3.3-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXi-1.7.10-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXi-1.7.10-1.el8.aarch64.rpm" || echo "Failed: libXi-1.7.10-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXinerama-1.1.4-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXinerama-1.1.4-1.el8.aarch64.rpm" || echo "Failed: libXinerama-1.1.4-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXrandr-1.5.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrandr-1.5.2-1.el8.aarch64.rpm" || echo "Failed: libXrandr-1.5.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXrender-0.9.10-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrender-0.9.10-7.el8.aarch64.rpm" || echo "Failed: libXrender-0.9.10-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXtst-1.2.3-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXtst-1.2.3-7.el8.aarch64.rpm" || echo "Failed: libXtst-1.2.3-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "libXxf86vm-1.1.4-9.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXxf86vm-1.1.4-9.el8.aarch64.rpm" || echo "Failed: libXxf86vm-1.1.4-9.el8.aarch64.rpm" && \
    curl -L -f -s -o "libdatrie-0.2.9-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdatrie-0.2.9-7.el8.aarch64.rpm" || echo "Failed: libdatrie-0.2.9-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "libdrm-2.4.115-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdrm-2.4.115-2.el8.aarch64.rpm" || echo "Failed: libdrm-2.4.115-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libepoxy-1.5.8-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libepoxy-1.5.8-1.el8.aarch64.rpm" || echo "Failed: libepoxy-1.5.8-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-egl-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-egl-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-egl-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libglvnd-glx-1.3.4-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-glx-1.3.4-2.el8.aarch64.rpm" || echo "Failed: libglvnd-glx-1.3.4-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" || echo "Failed: libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libthai-0.1.27-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libthai-0.1.27-2.el8.aarch64.rpm" || echo "Failed: libthai-0.1.27-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libtiff-4.0.9-36.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libtiff-4.0.9-36.el8_10.aarch64.rpm" || echo "Failed: libtiff-4.0.9-36.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-client-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-client-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-client-1.21.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-cursor-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-cursor-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-cursor-1.21.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-egl-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-egl-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-egl-1.21.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libwayland-server-1.21.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-server-1.21.0-1.el8.aarch64.rpm" || echo "Failed: libwayland-server-1.21.0-1.el8.aarch64.rpm" && \
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
    curl -L -f -s -o "rest-0.8.1-3.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/r/rest-0.8.1-3.el8_10.aarch64.rpm" || echo "Failed: rest-0.8.1-3.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "xkeyboard-config-2.28-1.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/x/xkeyboard-config-2.28-1.el8.noarch.rpm" || echo "Failed: xkeyboard-config-2.28-1.el8.noarch.rpm" && \
    curl -L -f -s -o "acl-2.2.53-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/acl-2.2.53-3.el8.aarch64.rpm" || echo "Failed: acl-2.2.53-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "audit-libs-3.1.2-1.el8_10.1.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/audit-libs-3.1.2-1.el8_10.1.aarch64.rpm" || echo "Failed: audit-libs-3.1.2-1.el8_10.1.aarch64.rpm" && \
    curl -L -f -s -o "avahi-libs-0.7-27.el8_10.1.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/avahi-libs-0.7-27.el8_10.1.aarch64.rpm" || echo "Failed: avahi-libs-0.7-27.el8_10.1.aarch64.rpm" && \
    curl -L -f -s -o "basesystem-11-5.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/basesystem-11-5.el8.noarch.rpm" || echo "Failed: basesystem-11-5.el8.noarch.rpm" && \
    curl -L -f -s -o "bash-4.4.20-6.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/bash-4.4.20-6.el8_10.aarch64.rpm" || echo "Failed: bash-4.4.20-6.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "brotli-1.0.6-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/brotli-1.0.6-3.el8.aarch64.rpm" || echo "Failed: brotli-1.0.6-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "bzip2-libs-1.0.6-28.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/bzip2-libs-1.0.6-28.el8_10.aarch64.rpm" || echo "Failed: bzip2-libs-1.0.6-28.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "ca-certificates-2025.2.80_v9.0.304-80.2.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/ca-certificates-2025.2.80_v9.0.304-80.2.el8_10.noarch.rpm" || echo "Failed: ca-certificates-2025.2.80_v9.0.304-80.2.el8_10.noarch.rpm" && \
    curl -L -f -s -o "chkconfig-1.19.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/chkconfig-1.19.2-1.el8.aarch64.rpm" || echo "Failed: chkconfig-1.19.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "coreutils-8.30-16.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/coreutils-8.30-16.el8_10.aarch64.rpm" || echo "Failed: coreutils-8.30-16.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "coreutils-common-8.30-16.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/coreutils-common-8.30-16.el8_10.aarch64.rpm" || echo "Failed: coreutils-common-8.30-16.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "cracklib-2.9.6-15.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cracklib-2.9.6-15.el8.aarch64.rpm" || echo "Failed: cracklib-2.9.6-15.el8.aarch64.rpm" && \
    curl -L -f -s -o "cracklib-dicts-2.9.6-15.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cracklib-dicts-2.9.6-15.el8.aarch64.rpm" || echo "Failed: cracklib-dicts-2.9.6-15.el8.aarch64.rpm" && \
    curl -L -f -s -o "crypto-policies-20230731-1.git3177e06.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/crypto-policies-20230731-1.git3177e06.el8.noarch.rpm" || echo "Failed: crypto-policies-20230731-1.git3177e06.el8.noarch.rpm" && \
    curl -L -f -s -o "crypto-policies-scripts-20230731-1.git3177e06.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/crypto-policies-scripts-20230731-1.git3177e06.el8.noarch.rpm" || echo "Failed: crypto-policies-scripts-20230731-1.git3177e06.el8.noarch.rpm" && \
    curl -L -f -s -o "cryptsetup-libs-2.3.7-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cryptsetup-libs-2.3.7-7.el8.aarch64.rpm" || echo "Failed: cryptsetup-libs-2.3.7-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "cups-libs-2.2.6-66.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cups-libs-2.2.6-66.el8_10.aarch64.rpm" || echo "Failed: cups-libs-2.2.6-66.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "cyrus-sasl-lib-2.1.27-6.el8_5.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cyrus-sasl-lib-2.1.27-6.el8_5.aarch64.rpm" || echo "Failed: cyrus-sasl-lib-2.1.27-6.el8_5.aarch64.rpm" && \
    curl -L -f -s -o "dbus-1.12.8-27.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-1.12.8-27.el8_10.aarch64.rpm" || echo "Failed: dbus-1.12.8-27.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "dbus-common-1.12.8-27.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-common-1.12.8-27.el8_10.noarch.rpm" || echo "Failed: dbus-common-1.12.8-27.el8_10.noarch.rpm" && \
    curl -L -f -s -o "dbus-daemon-1.12.8-27.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-daemon-1.12.8-27.el8_10.aarch64.rpm" || echo "Failed: dbus-daemon-1.12.8-27.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "dbus-libs-1.12.8-27.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-libs-1.12.8-27.el8_10.aarch64.rpm" || echo "Failed: dbus-libs-1.12.8-27.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "dbus-tools-1.12.8-27.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-tools-1.12.8-27.el8_10.aarch64.rpm" || echo "Failed: dbus-tools-1.12.8-27.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "dejavu-fonts-common-2.35-7.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-fonts-common-2.35-7.el8.noarch.rpm" || echo "Failed: dejavu-fonts-common-2.35-7.el8.noarch.rpm" && \
    curl -L -f -s -o "dejavu-sans-fonts-2.35-7.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-sans-fonts-2.35-7.el8.noarch.rpm" || echo "Failed: dejavu-sans-fonts-2.35-7.el8.noarch.rpm" && \
    curl -L -f -s -o "dejavu-sans-mono-fonts-2.35-7.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-sans-mono-fonts-2.35-7.el8.noarch.rpm" || echo "Failed: dejavu-sans-mono-fonts-2.35-7.el8.noarch.rpm" && \
    curl -L -f -s -o "device-mapper-1.02.181-15.el8_10.2.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/device-mapper-1.02.181-15.el8_10.2.aarch64.rpm" || echo "Failed: device-mapper-1.02.181-15.el8_10.2.aarch64.rpm" && \
    curl -L -f -s -o "device-mapper-libs-1.02.181-15.el8_10.2.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/device-mapper-libs-1.02.181-15.el8_10.2.aarch64.rpm" || echo "Failed: device-mapper-libs-1.02.181-15.el8_10.2.aarch64.rpm" && \
    curl -L -f -s -o "diffutils-3.6-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/diffutils-3.6-6.el8.aarch64.rpm" || echo "Failed: diffutils-3.6-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "elfutils-debuginfod-client-0.190-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-debuginfod-client-0.190-2.el8.aarch64.rpm" || echo "Failed: elfutils-debuginfod-client-0.190-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "elfutils-default-yama-scope-0.190-2.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-default-yama-scope-0.190-2.el8.noarch.rpm" || echo "Failed: elfutils-default-yama-scope-0.190-2.el8.noarch.rpm" && \
    curl -L -f -s -o "elfutils-libelf-0.190-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-libelf-0.190-2.el8.aarch64.rpm" || echo "Failed: elfutils-libelf-0.190-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "elfutils-libs-0.190-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-libs-0.190-2.el8.aarch64.rpm" || echo "Failed: elfutils-libs-0.190-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "expat-2.5.0-1.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/expat-2.5.0-1.el8_10.aarch64.rpm" || echo "Failed: expat-2.5.0-1.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "filesystem-3.8-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/filesystem-3.8-6.el8.aarch64.rpm" || echo "Failed: filesystem-3.8-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "fontconfig-2.13.1-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/fontconfig-2.13.1-4.el8.aarch64.rpm" || echo "Failed: fontconfig-2.13.1-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "fontpackages-filesystem-1.44-22.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/fontpackages-filesystem-1.44-22.el8.noarch.rpm" || echo "Failed: fontpackages-filesystem-1.44-22.el8.noarch.rpm" && \
    curl -L -f -s -o "freetype-2.9.1-10.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/freetype-2.9.1-10.el8_10.aarch64.rpm" || echo "Failed: freetype-2.9.1-10.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "gawk-4.2.1-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gawk-4.2.1-4.el8.aarch64.rpm" || echo "Failed: gawk-4.2.1-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "gdbm-1.18-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdbm-1.18-2.el8.aarch64.rpm" || echo "Failed: gdbm-1.18-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "gdbm-libs-1.18-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdbm-libs-1.18-2.el8.aarch64.rpm" || echo "Failed: gdbm-libs-1.18-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "gdk-pixbuf2-2.36.12-7.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdk-pixbuf2-2.36.12-7.el8_10.aarch64.rpm" || echo "Failed: gdk-pixbuf2-2.36.12-7.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "glib-networking-2.56.1-1.1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glib-networking-2.56.1-1.1.el8.aarch64.rpm" || echo "Failed: glib-networking-2.56.1-1.1.el8.aarch64.rpm" && \
    curl -L -f -s -o "glib2-2.56.4-167.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glib2-2.56.4-167.el8_10.aarch64.rpm" || echo "Failed: glib2-2.56.4-167.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "glibc-2.28-251.el8_10.27.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-2.28-251.el8_10.27.aarch64.rpm" || echo "Failed: glibc-2.28-251.el8_10.27.aarch64.rpm" && \
    curl -L -f -s -o "glibc-all-langpacks-2.28-251.el8_10.27.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-all-langpacks-2.28-251.el8_10.27.aarch64.rpm" || echo "Failed: glibc-all-langpacks-2.28-251.el8_10.27.aarch64.rpm" && \
    curl -L -f -s -o "glibc-common-2.28-251.el8_10.27.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-common-2.28-251.el8_10.27.aarch64.rpm" || echo "Failed: glibc-common-2.28-251.el8_10.27.aarch64.rpm" && \
    curl -L -f -s -o "glibc-gconv-extra-2.28-251.el8_10.27.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-gconv-extra-2.28-251.el8_10.27.aarch64.rpm" || echo "Failed: glibc-gconv-extra-2.28-251.el8_10.27.aarch64.rpm" && \
    curl -L -f -s -o "gmp-6.1.2-11.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gmp-6.1.2-11.el8.aarch64.rpm" || echo "Failed: gmp-6.1.2-11.el8.aarch64.rpm" && \
    curl -L -f -s -o "gnutls-3.6.16-8.el8_10.4.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gnutls-3.6.16-8.el8_10.4.aarch64.rpm" || echo "Failed: gnutls-3.6.16-8.el8_10.4.aarch64.rpm" && \
    curl -L -f -s -o "grep-3.1-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/grep-3.1-6.el8.aarch64.rpm" || echo "Failed: grep-3.1-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "gsettings-desktop-schemas-3.32.0-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gsettings-desktop-schemas-3.32.0-6.el8.aarch64.rpm" || echo "Failed: gsettings-desktop-schemas-3.32.0-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "gzip-1.9-13.el8_5.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gzip-1.9-13.el8_5.aarch64.rpm" || echo "Failed: gzip-1.9-13.el8_5.aarch64.rpm" && \
    curl -L -f -s -o "info-6.5-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/i/info-6.5-7.el8.aarch64.rpm" || echo "Failed: info-6.5-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "json-c-0.13.1-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/j/json-c-0.13.1-3.el8.aarch64.rpm" || echo "Failed: json-c-0.13.1-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "json-glib-1.4.4-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/j/json-glib-1.4.4-1.el8.aarch64.rpm" || echo "Failed: json-glib-1.4.4-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "keyutils-libs-1.5.10-9.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/keyutils-libs-1.5.10-9.el8.aarch64.rpm" || echo "Failed: keyutils-libs-1.5.10-9.el8.aarch64.rpm" && \
    curl -L -f -s -o "kmod-libs-25-20.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/kmod-libs-25-20.el8.aarch64.rpm" || echo "Failed: kmod-libs-25-20.el8.aarch64.rpm" && \
    curl -L -f -s -o "krb5-libs-1.18.2-32.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/krb5-libs-1.18.2-32.el8_10.aarch64.rpm" || echo "Failed: krb5-libs-1.18.2-32.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libacl-2.2.53-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libacl-2.2.53-3.el8.aarch64.rpm" || echo "Failed: libacl-2.2.53-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libattr-2.4.48-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libattr-2.4.48-3.el8.aarch64.rpm" || echo "Failed: libattr-2.4.48-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libblkid-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libblkid-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: libblkid-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libcap-2.48-6.el8_9.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcap-2.48-6.el8_9.aarch64.rpm" || echo "Failed: libcap-2.48-6.el8_9.aarch64.rpm" && \
    curl -L -f -s -o "libcap-ng-0.7.11-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcap-ng-0.7.11-1.el8.aarch64.rpm" || echo "Failed: libcap-ng-0.7.11-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libcom_err-1.45.6-7.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcom_err-1.45.6-7.el8_10.aarch64.rpm" || echo "Failed: libcom_err-1.45.6-7.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libcurl-7.61.1-34.el8_10.9.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcurl-7.61.1-34.el8_10.9.aarch64.rpm" || echo "Failed: libcurl-7.61.1-34.el8_10.9.aarch64.rpm" && \
    curl -L -f -s -o "libdb-5.3.28-42.el8_4.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libdb-5.3.28-42.el8_4.aarch64.rpm" || echo "Failed: libdb-5.3.28-42.el8_4.aarch64.rpm" && \
    curl -L -f -s -o "libevent-2.1.8-5.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libevent-2.1.8-5.el8.aarch64.rpm" || echo "Failed: libevent-2.1.8-5.el8.aarch64.rpm" && \
    curl -L -f -s -o "libfdisk-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libfdisk-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: libfdisk-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libffi-3.1-24.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libffi-3.1-24.el8.aarch64.rpm" || echo "Failed: libffi-3.1-24.el8.aarch64.rpm" && \
    curl -L -f -s -o "libgcc-8.5.0-28.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgcc-8.5.0-28.el8_10.aarch64.rpm" || echo "Failed: libgcc-8.5.0-28.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libgcrypt-1.8.5-7.el8_6.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgcrypt-1.8.5-7.el8_6.aarch64.rpm" || echo "Failed: libgcrypt-1.8.5-7.el8_6.aarch64.rpm" && \
    curl -L -f -s -o "libgpg-error-1.31-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgpg-error-1.31-1.el8.aarch64.rpm" || echo "Failed: libgpg-error-1.31-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libgusb-0.3.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgusb-0.3.0-1.el8.aarch64.rpm" || echo "Failed: libgusb-0.3.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libicu-60.3-2.el8_1.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libicu-60.3-2.el8_1.aarch64.rpm" || echo "Failed: libicu-60.3-2.el8_1.aarch64.rpm" && \
    curl -L -f -s -o "libidn2-2.2.0-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libidn2-2.2.0-1.el8.aarch64.rpm" || echo "Failed: libidn2-2.2.0-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libmodman-2.0.1-17.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libmodman-2.0.1-17.el8.aarch64.rpm" || echo "Failed: libmodman-2.0.1-17.el8.aarch64.rpm" && \
    curl -L -f -s -o "libmount-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libmount-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: libmount-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libnghttp2-1.33.0-6.el8_10.1.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libnghttp2-1.33.0-6.el8_10.1.aarch64.rpm" || echo "Failed: libnghttp2-1.33.0-6.el8_10.1.aarch64.rpm" && \
    curl -L -f -s -o "libnsl2-1.2.0-2.20180605git4a062cf.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libnsl2-1.2.0-2.20180605git4a062cf.el8.aarch64.rpm" || echo "Failed: libnsl2-1.2.0-2.20180605git4a062cf.el8.aarch64.rpm" && \
    curl -L -f -s -o "libpng-1.6.34-9.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpng-1.6.34-9.el8_10.aarch64.rpm" || echo "Failed: libpng-1.6.34-9.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libproxy-0.4.15-5.5.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libproxy-0.4.15-5.5.el8_10.aarch64.rpm" || echo "Failed: libproxy-0.4.15-5.5.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libpsl-0.20.2-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpsl-0.20.2-6.el8.aarch64.rpm" || echo "Failed: libpsl-0.20.2-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "libpwquality-1.4.4-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpwquality-1.4.4-6.el8.aarch64.rpm" || echo "Failed: libpwquality-1.4.4-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "libseccomp-2.5.2-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libseccomp-2.5.2-1.el8.aarch64.rpm" || echo "Failed: libseccomp-2.5.2-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libsecret-0.18.6-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsecret-0.18.6-1.el8.aarch64.rpm" || echo "Failed: libsecret-0.18.6-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "libselinux-2.9-10.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libselinux-2.9-10.el8_10.aarch64.rpm" || echo "Failed: libselinux-2.9-10.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libsemanage-2.9-12.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsemanage-2.9-12.el8_10.aarch64.rpm" || echo "Failed: libsemanage-2.9-12.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libsepol-2.9-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsepol-2.9-3.el8.aarch64.rpm" || echo "Failed: libsepol-2.9-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libsigsegv-2.11-5.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsigsegv-2.11-5.el8.aarch64.rpm" || echo "Failed: libsigsegv-2.11-5.el8.aarch64.rpm" && \
    curl -L -f -s -o "libsmartcols-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsmartcols-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: libsmartcols-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libsoup-2.62.3-11.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsoup-2.62.3-11.el8_10.aarch64.rpm" || echo "Failed: libsoup-2.62.3-11.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libssh-0.9.6-16.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libssh-0.9.6-16.el8_10.aarch64.rpm" || echo "Failed: libssh-0.9.6-16.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libssh-config-0.9.6-16.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libssh-config-0.9.6-16.el8_10.noarch.rpm" || echo "Failed: libssh-config-0.9.6-16.el8_10.noarch.rpm" && \
    curl -L -f -s -o "libstdc++-8.5.0-28.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libstdc++-8.5.0-28.el8_10.aarch64.rpm" || echo "Failed: libstdc++-8.5.0-28.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libtasn1-4.13-5.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libtasn1-4.13-5.el8_10.aarch64.rpm" || echo "Failed: libtasn1-4.13-5.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libtirpc-1.1.4-12.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libtirpc-1.1.4-12.el8_10.aarch64.rpm" || echo "Failed: libtirpc-1.1.4-12.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libunistring-0.9.9-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libunistring-0.9.9-3.el8.aarch64.rpm" || echo "Failed: libunistring-0.9.9-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "libusbx-1.0.23-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libusbx-1.0.23-4.el8.aarch64.rpm" || echo "Failed: libusbx-1.0.23-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "libutempter-1.1.6-14.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libutempter-1.1.6-14.el8.aarch64.rpm" || echo "Failed: libutempter-1.1.6-14.el8.aarch64.rpm" && \
    curl -L -f -s -o "libuuid-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libuuid-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: libuuid-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libverto-0.3.2-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libverto-0.3.2-2.el8.aarch64.rpm" || echo "Failed: libverto-0.3.2-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "libxcrypt-4.1.1-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxcrypt-4.1.1-6.el8.aarch64.rpm" || echo "Failed: libxcrypt-4.1.1-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "libxml2-2.9.7-21.el8_10.3.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxml2-2.9.7-21.el8_10.3.aarch64.rpm" || echo "Failed: libxml2-2.9.7-21.el8_10.3.aarch64.rpm" && \
    curl -L -f -s -o "libxslt-1.1.32-6.3.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxslt-1.1.32-6.3.el8_10.aarch64.rpm" || echo "Failed: libxslt-1.1.32-6.3.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "libzstd-1.4.4-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libzstd-1.4.4-1.el8.aarch64.rpm" || echo "Failed: libzstd-1.4.4-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "lz4-libs-1.8.3-5.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/lz4-libs-1.8.3-5.el8_10.aarch64.rpm" || echo "Failed: lz4-libs-1.8.3-5.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "mpfr-3.1.6-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/m/mpfr-3.1.6-1.el8.aarch64.rpm" || echo "Failed: mpfr-3.1.6-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "ncurses-6.1-10.20180224.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-6.1-10.20180224.el8.aarch64.rpm" || echo "Failed: ncurses-6.1-10.20180224.el8.aarch64.rpm" && \
    curl -L -f -s -o "ncurses-base-6.1-10.20180224.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-base-6.1-10.20180224.el8.noarch.rpm" || echo "Failed: ncurses-base-6.1-10.20180224.el8.noarch.rpm" && \
    curl -L -f -s -o "ncurses-libs-6.1-10.20180224.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-libs-6.1-10.20180224.el8.aarch64.rpm" || echo "Failed: ncurses-libs-6.1-10.20180224.el8.aarch64.rpm" && \
    curl -L -f -s -o "nettle-3.4.1-7.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/nettle-3.4.1-7.el8.aarch64.rpm" || echo "Failed: nettle-3.4.1-7.el8.aarch64.rpm" && \
    curl -L -f -s -o "openldap-2.4.46-21.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openldap-2.4.46-21.el8_10.aarch64.rpm" || echo "Failed: openldap-2.4.46-21.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "openssl-1.1.1k-14.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-1.1.1k-14.el8_10.aarch64.rpm" || echo "Failed: openssl-1.1.1k-14.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "openssl-libs-1.1.1k-14.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-libs-1.1.1k-14.el8_10.aarch64.rpm" || echo "Failed: openssl-libs-1.1.1k-14.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "openssl-pkcs11-0.4.10-3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-pkcs11-0.4.10-3.el8.aarch64.rpm" || echo "Failed: openssl-pkcs11-0.4.10-3.el8.aarch64.rpm" && \
    curl -L -f -s -o "p11-kit-0.23.22-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/p11-kit-0.23.22-2.el8.aarch64.rpm" || echo "Failed: p11-kit-0.23.22-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "p11-kit-trust-0.23.22-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/p11-kit-trust-0.23.22-2.el8.aarch64.rpm" || echo "Failed: p11-kit-trust-0.23.22-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "pam-1.3.1-39.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pam-1.3.1-39.el8_10.aarch64.rpm" || echo "Failed: pam-1.3.1-39.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "pcre-8.42-6.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pcre-8.42-6.el8.aarch64.rpm" || echo "Failed: pcre-8.42-6.el8.aarch64.rpm" && \
    curl -L -f -s -o "pcre2-10.32-3.el8_6.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pcre2-10.32-3.el8_6.aarch64.rpm" || echo "Failed: pcre2-10.32-3.el8_6.aarch64.rpm" && \
    curl -L -f -s -o "platform-python-3.6.8-71.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-3.6.8-71.el8_10.aarch64.rpm" || echo "Failed: platform-python-3.6.8-71.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "platform-python-pip-9.0.3-24.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-pip-9.0.3-24.el8.noarch.rpm" || echo "Failed: platform-python-pip-9.0.3-24.el8.noarch.rpm" && \
    curl -L -f -s -o "platform-python-setuptools-39.2.0-9.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-setuptools-39.2.0-9.el8_10.noarch.rpm" || echo "Failed: platform-python-setuptools-39.2.0-9.el8_10.noarch.rpm" && \
    curl -L -f -s -o "popt-1.18-1.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/popt-1.18-1.el8.aarch64.rpm" || echo "Failed: popt-1.18-1.el8.aarch64.rpm" && \
    curl -L -f -s -o "publicsuffix-list-dafsa-20180723-1.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/publicsuffix-list-dafsa-20180723-1.el8.noarch.rpm" || echo "Failed: publicsuffix-list-dafsa-20180723-1.el8.noarch.rpm" && \
    curl -L -f -s -o "python3-libs-3.6.8-71.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-libs-3.6.8-71.el8_10.aarch64.rpm" || echo "Failed: python3-libs-3.6.8-71.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "python3-pip-wheel-9.0.3-24.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-pip-wheel-9.0.3-24.el8.noarch.rpm" || echo "Failed: python3-pip-wheel-9.0.3-24.el8.noarch.rpm" && \
    curl -L -f -s -o "python3-setuptools-wheel-39.2.0-9.el8_10.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-setuptools-wheel-39.2.0-9.el8_10.noarch.rpm" || echo "Failed: python3-setuptools-wheel-39.2.0-9.el8_10.noarch.rpm" && \
    curl -L -f -s -o "readline-7.0-10.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/r/readline-7.0-10.el8.aarch64.rpm" || echo "Failed: readline-7.0-10.el8.aarch64.rpm" && \
    curl -L -f -s -o "redhat-release-8.10-0.3.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/r/redhat-release-8.10-0.3.el8.aarch64.rpm" || echo "Failed: redhat-release-8.10-0.3.el8.aarch64.rpm" && \
    curl -L -f -s -o "sed-4.5-5.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/sed-4.5-5.el8.aarch64.rpm" || echo "Failed: sed-4.5-5.el8.aarch64.rpm" && \
    curl -L -f -s -o "setup-2.12.2-9.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/setup-2.12.2-9.el8.noarch.rpm" || echo "Failed: setup-2.12.2-9.el8.noarch.rpm" && \
    curl -L -f -s -o "shadow-utils-4.6-23.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/shadow-utils-4.6-23.el8_10.aarch64.rpm" || echo "Failed: shadow-utils-4.6-23.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "shared-mime-info-1.9-4.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/shared-mime-info-1.9-4.el8.aarch64.rpm" || echo "Failed: shared-mime-info-1.9-4.el8.aarch64.rpm" && \
    curl -L -f -s -o "sqlite-libs-3.26.0-20.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/sqlite-libs-3.26.0-20.el8_10.aarch64.rpm" || echo "Failed: sqlite-libs-3.26.0-20.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "systemd-239-82.el8_10.8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-239-82.el8_10.8.aarch64.rpm" || echo "Failed: systemd-239-82.el8_10.8.aarch64.rpm" && \
    curl -L -f -s -o "systemd-libs-239-82.el8_10.8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-libs-239-82.el8_10.8.aarch64.rpm" || echo "Failed: systemd-libs-239-82.el8_10.8.aarch64.rpm" && \
    curl -L -f -s -o "systemd-pam-239-82.el8_10.8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-pam-239-82.el8_10.8.aarch64.rpm" || echo "Failed: systemd-pam-239-82.el8_10.8.aarch64.rpm" && \
    curl -L -f -s -o "trousers-0.3.15-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/trousers-0.3.15-2.el8.aarch64.rpm" || echo "Failed: trousers-0.3.15-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "trousers-lib-0.3.15-2.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/trousers-lib-0.3.15-2.el8.aarch64.rpm" || echo "Failed: trousers-lib-0.3.15-2.el8.aarch64.rpm" && \
    curl -L -f -s -o "tzdata-2025c-1.el8.noarch.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/tzdata-2025c-1.el8.noarch.rpm" || echo "Failed: tzdata-2025c-1.el8.noarch.rpm" && \
    curl -L -f -s -o "util-linux-2.32.1-47.el8_10.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/u/util-linux-2.32.1-47.el8_10.aarch64.rpm" || echo "Failed: util-linux-2.32.1-47.el8_10.aarch64.rpm" && \
    curl -L -f -s -o "xz-libs-5.2.4-4.el8_6.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/x/xz-libs-5.2.4-4.el8_6.aarch64.rpm" || echo "Failed: xz-libs-5.2.4-4.el8_6.aarch64.rpm" && \
    curl -L -f -s -o "zlib-1.2.11-25.el8.aarch64.rpm" "https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/z/zlib-1.2.11-25.el8.aarch64.rpm" || echo "Failed: zlib-1.2.11-25.el8.aarch64.rpm" && \
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

# Install Chromium using Playwright's install command, then move it to our custom location
# This ensures we get the exact version (1194) that Playwright 1.56.1 expects
RUN npx playwright install chromium && \
    PLAYWRIGHT_BROWSER_PATH=$(find /root/.cache/ms-playwright -name "chrome-linux" -type d | head -1) && \
    if [ -z "$PLAYWRIGHT_BROWSER_PATH" ]; then \
        echo "Error: Playwright Chromium not found"; \
        find /root/.cache/ms-playwright -type d | head -10; \
        exit 1; \
    fi && \
    mkdir -p /opt/playwright-chromium && \
    CHROMIUM_DIR=$(dirname "$PLAYWRIGHT_BROWSER_PATH") && \
    cp -r "$CHROMIUM_DIR" /opt/playwright-chromium/ && \
    CHROMIUM_BIN=$(find /opt/playwright-chromium -name "chrome" -type f | head -1) && \
    if [ -z "$CHROMIUM_BIN" ]; then \
        echo "Error: Chromium binary not found after copy"; \
        find /opt/playwright-chromium -type f | head -10; \
        exit 1; \
    fi && \
    chmod +x "$CHROMIUM_BIN" && \
    ln -sf "$CHROMIUM_BIN" /opt/playwright-chromium/chrome && \
    echo "Chromium installed at /opt/playwright-chromium/chrome" && \
    /opt/playwright-chromium/chrome --version || echo "Version check failed, but binary exists"

# Install Firefox and WebKit from Playwright
RUN npx playwright install firefox webkit

# Install Playwright system dependencies (for Firefox and WebKit)
RUN npx playwright install-deps || echo "Some dependencies may already be installed"

# Copy application files
COPY . .

# Set environment variables
ENV NODE_ENV=production
# Set Chromium executable path for Playwright (headless mode)
ENV PLAYWRIGHT_CHROMIUM_PATH=/opt/playwright-chromium/chrome

# Default command
CMD ["npm", "test"]
