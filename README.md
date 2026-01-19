# Containerized Playwright for OpenShift

This project provides a Docker container with Playwright, TypeScript, and Node.js configured to run Playwright test scripts.

## Specifications

- **Base Image**: Red Hat UBI 8.10 (RHEL 8.10 Ootpa) - `registry.access.redhat.com/ubi8:8.10`
- **OpenJDK**: 21
- **Playwright**: 1.56.1
- **@playwright/test**: 1.56.1
- **TypeScript**: 5.4.5
- **Node.js**: 20.x
- **npm**: 10.8.2
- **Chromium**: Version 1194 (Playwright's specific build, downloaded as zip)

## Building the Container

### Option 1: Using Docker directly
```bash
docker build -t playwright-container:latest .
```

### Option 2: Using build script
```bash
chmod +x build.sh
./build.sh
```

### Option 3: Using Docker Compose
```bash
docker-compose build
```

## Running Tests

### Option 1: Using Docker directly
```bash
# Run all tests
docker run --rm playwright-container:latest

# Run with volume mounts for test results
docker run --rm \
  -v "$(pwd)/tests:/app/tests" \
  -v "$(pwd)/test-results:/app/test-results" \
  -v "$(pwd)/playwright-report:/app/playwright-report" \
  playwright-container:latest

# Run tests in headed mode (requires X11 forwarding)
docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix playwright-container:latest npm run test:headed

# Run specific test file
docker run --rm playwright-container:latest npx playwright test tests/example.spec.ts
```

### Option 2: Using run script
```bash
chmod +x run.sh
./run.sh
```

### Option 3: Using Docker Compose
```bash
# Run tests
docker-compose up

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop container
docker-compose down
```

## Project Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml     # Docker Compose configuration
├── build.sh               # Build script
├── run.sh                 # Run script
├── package.json           # Node.js dependencies
├── tsconfig.json          # TypeScript configuration
├── playwright.config.ts   # Playwright configuration
├── tests/                 # Test files directory
│   └── example.spec.ts    # Example test
└── README.md              # This file
```

## Adding Your Tests

Place your Playwright test files in the `tests/` directory. Tests should be written in TypeScript and use the `@playwright/test` framework.

## Browser Installation

- **Chromium**: Downloaded as a separate zip file from Playwright's CDN (version 1194, matching Playwright 1.56.1)
  - Location: `/opt/playwright-chromium/chrome` (symlink to the extracted Chromium binary)
  - Installed separately to match Playwright's exact browser version requirements
  - Configured in `playwright.config.ts` via `executablePath`
- **Firefox & WebKit**: Installed via Playwright's `playwright install` command

## Low-Level Binaries and Dependencies

This container downloads and installs several low-level system libraries and binaries required for Chromium to run in headless mode. The RPM packages are downloaded from Red Hat UBI repositories and stored separately before installation.

### RPM Package Storage

- **Storage Location**: `/opt/rpms/playwright-deps/`
- **Version Documentation**: `/opt/rpms/package-versions.txt`
- **Repository URLs**: `/opt/rpms/repository-urls.txt`
- **Download Method**: Downloads RPMs directly from Red Hat UBI repository URLs using `curl`
- **Installation**: Packages are installed from local RPM files using `dnf localinstall`

You can inspect downloaded packages:
```bash
docker run --rm playwright-container:latest ls -lh /opt/rpms/playwright-deps/
docker run --rm playwright-container:latest cat /opt/rpms/package-versions.txt
docker run --rm playwright-container:latest cat /opt/rpms/repository-urls.txt
```

### RPM Package Download Links

All RPM packages are downloaded directly from Red Hat UBI 8 repositories. The complete list of 217 packages with their direct download URLs is available in the container at `/opt/rpms/repository-urls.txt`.

**Repository Base URLs:**
- **AppStream**: `https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/`
- **BaseOS**: `https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/`

**Key Package Categories and Download Links:**

#### Graphics and Display Libraries
- [libX11](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-1.6.8-9.el8_10.aarch64.rpm)
- [libX11-common](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-common-1.6.8-9.el8_10.noarch.rpm)
- [libX11-xcb](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-xcb-1.6.8-9.el8_10.aarch64.rpm)
- [libXScrnSaver](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXScrnSaver-1.2.3-1.el8.aarch64.rpm)
- [libXcomposite](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcomposite-0.4.4-14.el8.aarch64.rpm)
- [libXcursor](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcursor-1.1.15-3.el8.aarch64.rpm)
- [libXdamage](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXdamage-1.1.4-14.el8.aarch64.rpm)
- [libXext](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXext-1.3.4-1.el8.aarch64.rpm)
- [libXi](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXi-1.7.10-1.el8.aarch64.rpm)
- [libXrandr](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrandr-1.5.2-1.el8.aarch64.rpm)
- [libXtst](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXtst-1.2.3-7.el8.aarch64.rpm)
- [libdrm](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdrm-2.4.115-2.el8.aarch64.rpm)
- [libxkbcommon](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxkbcommon-0.9.1-1.el8.aarch64.rpm)
- [libxshmfence](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxshmfence-1.3-2.el8.aarch64.rpm)
- [mesa-libgbm](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libgbm-23.1.4-4.el8_10.aarch64.rpm)
- [mesa-libEGL](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libEGL-23.1.4-4.el8_10.aarch64.rpm)
- [mesa-libGL](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libGL-23.1.4-4.el8_10.aarch64.rpm)

#### UI and Widget Libraries
- [atk](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/atk-2.28.1-1.el8.aarch64.rpm)
- [cups-libs](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cups-libs-2.2.6-66.el8_10.aarch64.rpm)
- [gtk3](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gtk3-3.22.30-12.el8_10.aarch64.rpm)
- [pango](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/p/pango-1.42.4-8.el8.aarch64.rpm)
- [harfbuzz](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/harfbuzz-1.7.5-4.el8.aarch64.rpm)

#### Security and Network Libraries
- [nss](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-3.112.0-4.el8_10.aarch64.rpm)

#### Audio Libraries
- [alsa-lib](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/alsa-lib-1.2.10-2.el8.aarch64.rpm)

#### Other Essential Libraries
- [libicu](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libicu-60.3-2.el8_1.aarch64.rpm)
- [libxslt](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxslt-1.1.32-6.3.el8_10.aarch64.rpm)
- [libevent](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libevent-2.1.8-5.el8.aarch64.rpm)
- [libwebp](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwebp-1.0.0-11.el8_10.aarch64.rpm)
- [libjpeg-turbo](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm)
- [enchant](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/e/enchant-1.6.0-21.el8.aarch64.rpm)
- [libsecret](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libsecret-0.18.6-1.el8.aarch64.rpm)
- [libffi](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libffi-3.1-24.el8.aarch64.rpm)

#### Complete List of All RPM Download Links (217 packages)

All RPM packages are downloaded from Red Hat UBI 8 repositories. Below is the complete list of all 217 package download URLs:

<details>
<summary>Click to expand complete list of all 217 RPM download URLs</summary>

- [abattis-cantarell-fonts-0.0.25-6.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/abattis-cantarell-fonts-0.0.25-6.el8.noarch.rpm)
- [adwaita-cursor-theme-3.28.0-3.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/adwaita-cursor-theme-3.28.0-3.el8.noarch.rpm)
- [adwaita-icon-theme-3.28.0-3.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/adwaita-icon-theme-3.28.0-3.el8.noarch.rpm)
- [alsa-lib-1.2.10-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/alsa-lib-1.2.10-2.el8.aarch64.rpm)
- [at-spi2-atk-2.26.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/at-spi2-atk-2.26.2-1.el8.aarch64.rpm)
- [at-spi2-core-2.28.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/at-spi2-core-2.28.0-1.el8.aarch64.rpm)
- [atk-2.28.1-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/a/atk-2.28.1-1.el8.aarch64.rpm)
- [cairo-1.15.12-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-1.15.12-6.el8.aarch64.rpm)
- [cairo-gobject-1.15.12-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/cairo-gobject-1.15.12-6.el8.aarch64.rpm)
- [colord-libs-1.4.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/c/colord-libs-1.4.2-1.el8.aarch64.rpm)
- [dconf-0.28.0-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/d/dconf-0.28.0-4.el8.aarch64.rpm)
- [enchant-1.6.0-21.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/e/enchant-1.6.0-21.el8.aarch64.rpm)
- [fribidi-1.0.4-9.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/f/fribidi-1.0.4-9.el8.aarch64.rpm)
- [gdk-pixbuf2-modules-2.36.12-7.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gdk-pixbuf2-modules-2.36.12-7.el8_10.aarch64.rpm)
- [graphite2-1.3.10-10.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/graphite2-1.3.10-10.el8.aarch64.rpm)
- [gtk-update-icon-cache-3.22.30-12.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gtk-update-icon-cache-3.22.30-12.el8_10.aarch64.rpm)
- [gtk3-3.22.30-12.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/g/gtk3-3.22.30-12.el8_10.aarch64.rpm)
- [harfbuzz-1.7.5-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/harfbuzz-1.7.5-4.el8.aarch64.rpm)
- [hicolor-icon-theme-0.17-2.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hicolor-icon-theme-0.17-2.el8.noarch.rpm)
- [hunspell-1.6.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hunspell-1.6.2-1.el8.aarch64.rpm)
- [hunspell-en-US-0.20140811.1-12.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/h/hunspell-en-US-0.20140811.1-12.el8.noarch.rpm)
- [jasper-libs-2.0.14-6.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/j/jasper-libs-2.0.14-6.el8_10.aarch64.rpm)
- [jbigkit-libs-2.1-14.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/j/jbigkit-libs-2.1-14.el8.aarch64.rpm)
- [lcms2-2.9-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/lcms2-2.9-2.el8.aarch64.rpm)
- [libX11-1.6.8-9.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-1.6.8-9.el8_10.aarch64.rpm)
- [libX11-common-1.6.8-9.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-common-1.6.8-9.el8_10.noarch.rpm)
- [libX11-xcb-1.6.8-9.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libX11-xcb-1.6.8-9.el8_10.aarch64.rpm)
- [libXScrnSaver-1.2.3-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXScrnSaver-1.2.3-1.el8.aarch64.rpm)
- [libXau-1.0.9-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXau-1.0.9-3.el8.aarch64.rpm)
- [libXcomposite-0.4.4-14.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcomposite-0.4.4-14.el8.aarch64.rpm)
- [libXcursor-1.1.15-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXcursor-1.1.15-3.el8.aarch64.rpm)
- [libXdamage-1.1.4-14.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXdamage-1.1.4-14.el8.aarch64.rpm)
- [libXext-1.3.4-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXext-1.3.4-1.el8.aarch64.rpm)
- [libXfixes-5.0.3-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXfixes-5.0.3-7.el8.aarch64.rpm)
- [libXft-2.3.3-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXft-2.3.3-1.el8.aarch64.rpm)
- [libXi-1.7.10-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXi-1.7.10-1.el8.aarch64.rpm)
- [libXinerama-1.1.4-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXinerama-1.1.4-1.el8.aarch64.rpm)
- [libXrandr-1.5.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrandr-1.5.2-1.el8.aarch64.rpm)
- [libXrender-0.9.10-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXrender-0.9.10-7.el8.aarch64.rpm)
- [libXtst-1.2.3-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXtst-1.2.3-7.el8.aarch64.rpm)
- [libXxf86vm-1.1.4-9.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libXxf86vm-1.1.4-9.el8.aarch64.rpm)
- [libdatrie-0.2.9-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdatrie-0.2.9-7.el8.aarch64.rpm)
- [libdrm-2.4.115-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libdrm-2.4.115-2.el8.aarch64.rpm)
- [libepoxy-1.5.8-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libepoxy-1.5.8-1.el8.aarch64.rpm)
- [libglvnd-1.3.4-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-1.3.4-2.el8.aarch64.rpm)
- [libglvnd-egl-1.3.4-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-egl-1.3.4-2.el8.aarch64.rpm)
- [libglvnd-glx-1.3.4-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libglvnd-glx-1.3.4-2.el8.aarch64.rpm)
- [libjpeg-turbo-1.5.3-14.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libjpeg-turbo-1.5.3-14.el8_10.aarch64.rpm)
- [libthai-0.1.27-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libthai-0.1.27-2.el8.aarch64.rpm)
- [libtiff-4.0.9-36.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libtiff-4.0.9-36.el8_10.aarch64.rpm)
- [libwayland-client-1.21.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-client-1.21.0-1.el8.aarch64.rpm)
- [libwayland-cursor-1.21.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-cursor-1.21.0-1.el8.aarch64.rpm)
- [libwayland-egl-1.21.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-egl-1.21.0-1.el8.aarch64.rpm)
- [libwayland-server-1.21.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwayland-server-1.21.0-1.el8.aarch64.rpm)
- [libwebp-1.0.0-11.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libwebp-1.0.0-11.el8_10.aarch64.rpm)
- [libxcb-1.13.1-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxcb-1.13.1-1.el8.aarch64.rpm)
- [libxkbcommon-0.9.1-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxkbcommon-0.9.1-1.el8.aarch64.rpm)
- [libxshmfence-1.3-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/l/libxshmfence-1.3-2.el8.aarch64.rpm)
- [mesa-libEGL-23.1.4-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libEGL-23.1.4-4.el8_10.aarch64.rpm)
- [mesa-libGL-23.1.4-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libGL-23.1.4-4.el8_10.aarch64.rpm)
- [mesa-libgbm-23.1.4-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libgbm-23.1.4-4.el8_10.aarch64.rpm)
- [mesa-libglapi-23.1.4-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/m/mesa-libglapi-23.1.4-4.el8_10.aarch64.rpm)
- [nspr-4.36.0-2.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nspr-4.36.0-2.el8_10.aarch64.rpm)
- [nss-3.112.0-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-3.112.0-4.el8_10.aarch64.rpm)
- [nss-softokn-3.112.0-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-softokn-3.112.0-4.el8_10.aarch64.rpm)
- [nss-softokn-freebl-3.112.0-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-softokn-freebl-3.112.0-4.el8_10.aarch64.rpm)
- [nss-sysinit-3.112.0-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-sysinit-3.112.0-4.el8_10.aarch64.rpm)
- [nss-util-3.112.0-4.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/n/nss-util-3.112.0-4.el8_10.aarch64.rpm)
- [pango-1.42.4-8.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/p/pango-1.42.4-8.el8.aarch64.rpm)
- [pixman-0.38.4-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/p/pixman-0.38.4-4.el8.aarch64.rpm)
- [rest-0.8.1-3.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/r/rest-0.8.1-3.el8_10.aarch64.rpm)
- [xkeyboard-config-2.28-1.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/appstream/os/Packages/x/xkeyboard-config-2.28-1.el8.noarch.rpm)
- [acl-2.2.53-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/acl-2.2.53-3.el8.aarch64.rpm)
- [audit-libs-3.1.2-1.el8_10.1.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/audit-libs-3.1.2-1.el8_10.1.aarch64.rpm)
- [avahi-libs-0.7-27.el8_10.1.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/a/avahi-libs-0.7-27.el8_10.1.aarch64.rpm)
- [basesystem-11-5.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/basesystem-11-5.el8.noarch.rpm)
- [bash-4.4.20-6.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/bash-4.4.20-6.el8_10.aarch64.rpm)
- [brotli-1.0.6-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/brotli-1.0.6-3.el8.aarch64.rpm)
- [bzip2-libs-1.0.6-28.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/b/bzip2-libs-1.0.6-28.el8_10.aarch64.rpm)
- [ca-certificates-2025.2.80_v9.0.304-80.2.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/ca-certificates-2025.2.80_v9.0.304-80.2.el8_10.noarch.rpm)
- [chkconfig-1.19.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/chkconfig-1.19.2-1.el8.aarch64.rpm)
- [coreutils-8.30-16.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/coreutils-8.30-16.el8_10.aarch64.rpm)
- [coreutils-common-8.30-16.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/coreutils-common-8.30-16.el8_10.aarch64.rpm)
- [cracklib-2.9.6-15.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cracklib-2.9.6-15.el8.aarch64.rpm)
- [cracklib-dicts-2.9.6-15.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cracklib-dicts-2.9.6-15.el8.aarch64.rpm)
- [crypto-policies-20230731-1.git3177e06.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/crypto-policies-20230731-1.git3177e06.el8.noarch.rpm)
- [crypto-policies-scripts-20230731-1.git3177e06.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/crypto-policies-scripts-20230731-1.git3177e06.el8.noarch.rpm)
- [cryptsetup-libs-2.3.7-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cryptsetup-libs-2.3.7-7.el8.aarch64.rpm)
- [cups-libs-2.2.6-66.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cups-libs-2.2.6-66.el8_10.aarch64.rpm)
- [cyrus-sasl-lib-2.1.27-6.el8_5.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/c/cyrus-sasl-lib-2.1.27-6.el8_5.aarch64.rpm)
- [dbus-1.12.8-27.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-1.12.8-27.el8_10.aarch64.rpm)
- [dbus-common-1.12.8-27.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-common-1.12.8-27.el8_10.noarch.rpm)
- [dbus-daemon-1.12.8-27.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-daemon-1.12.8-27.el8_10.aarch64.rpm)
- [dbus-libs-1.12.8-27.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-libs-1.12.8-27.el8_10.aarch64.rpm)
- [dbus-tools-1.12.8-27.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dbus-tools-1.12.8-27.el8_10.aarch64.rpm)
- [dejavu-fonts-common-2.35-7.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-fonts-common-2.35-7.el8.noarch.rpm)
- [dejavu-sans-fonts-2.35-7.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-sans-fonts-2.35-7.el8.noarch.rpm)
- [dejavu-sans-mono-fonts-2.35-7.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/dejavu-sans-mono-fonts-2.35-7.el8.noarch.rpm)
- [device-mapper-1.02.181-15.el8_10.2.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/device-mapper-1.02.181-15.el8_10.2.aarch64.rpm)
- [device-mapper-libs-1.02.181-15.el8_10.2.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/device-mapper-libs-1.02.181-15.el8_10.2.aarch64.rpm)
- [diffutils-3.6-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/d/diffutils-3.6-6.el8.aarch64.rpm)
- [elfutils-debuginfod-client-0.190-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-debuginfod-client-0.190-2.el8.aarch64.rpm)
- [elfutils-default-yama-scope-0.190-2.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-default-yama-scope-0.190-2.el8.noarch.rpm)
- [elfutils-libelf-0.190-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-libelf-0.190-2.el8.aarch64.rpm)
- [elfutils-libs-0.190-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/elfutils-libs-0.190-2.el8.aarch64.rpm)
- [expat-2.5.0-1.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/e/expat-2.5.0-1.el8_10.aarch64.rpm)
- [filesystem-3.8-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/filesystem-3.8-6.el8.aarch64.rpm)
- [fontconfig-2.13.1-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/fontconfig-2.13.1-4.el8.aarch64.rpm)
- [fontpackages-filesystem-1.44-22.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/fontpackages-filesystem-1.44-22.el8.noarch.rpm)
- [freetype-2.9.1-10.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/f/freetype-2.9.1-10.el8_10.aarch64.rpm)
- [gawk-4.2.1-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gawk-4.2.1-4.el8.aarch64.rpm)
- [gdbm-1.18-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdbm-1.18-2.el8.aarch64.rpm)
- [gdbm-libs-1.18-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdbm-libs-1.18-2.el8.aarch64.rpm)
- [gdk-pixbuf2-2.36.12-7.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gdk-pixbuf2-2.36.12-7.el8_10.aarch64.rpm)
- [glib-networking-2.56.1-1.1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glib-networking-2.56.1-1.1.el8.aarch64.rpm)
- [glib2-2.56.4-167.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glib2-2.56.4-167.el8_10.aarch64.rpm)
- [glibc-2.28-251.el8_10.27.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-2.28-251.el8_10.27.aarch64.rpm)
- [glibc-all-langpacks-2.28-251.el8_10.27.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-all-langpacks-2.28-251.el8_10.27.aarch64.rpm)
- [glibc-common-2.28-251.el8_10.27.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-common-2.28-251.el8_10.27.aarch64.rpm)
- [glibc-gconv-extra-2.28-251.el8_10.27.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/glibc-gconv-extra-2.28-251.el8_10.27.aarch64.rpm)
- [gmp-6.1.2-11.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gmp-6.1.2-11.el8.aarch64.rpm)
- [gnutls-3.6.16-8.el8_10.4.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gnutls-3.6.16-8.el8_10.4.aarch64.rpm)
- [grep-3.1-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/grep-3.1-6.el8.aarch64.rpm)
- [gsettings-desktop-schemas-3.32.0-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gsettings-desktop-schemas-3.32.0-6.el8.aarch64.rpm)
- [gzip-1.9-13.el8_5.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/g/gzip-1.9-13.el8_5.aarch64.rpm)
- [info-6.5-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/i/info-6.5-7.el8.aarch64.rpm)
- [json-c-0.13.1-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/j/json-c-0.13.1-3.el8.aarch64.rpm)
- [json-glib-1.4.4-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/j/json-glib-1.4.4-1.el8.aarch64.rpm)
- [keyutils-libs-1.5.10-9.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/keyutils-libs-1.5.10-9.el8.aarch64.rpm)
- [kmod-libs-25-20.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/kmod-libs-25-20.el8.aarch64.rpm)
- [krb5-libs-1.18.2-32.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/k/krb5-libs-1.18.2-32.el8_10.aarch64.rpm)
- [libacl-2.2.53-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libacl-2.2.53-3.el8.aarch64.rpm)
- [libattr-2.4.48-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libattr-2.4.48-3.el8.aarch64.rpm)
- [libblkid-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libblkid-2.32.1-47.el8_10.aarch64.rpm)
- [libcap-2.48-6.el8_9.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcap-2.48-6.el8_9.aarch64.rpm)
- [libcap-ng-0.7.11-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcap-ng-0.7.11-1.el8.aarch64.rpm)
- [libcom_err-1.45.6-7.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcom_err-1.45.6-7.el8_10.aarch64.rpm)
- [libcurl-7.61.1-34.el8_10.9.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libcurl-7.61.1-34.el8_10.9.aarch64.rpm)
- [libdb-5.3.28-42.el8_4.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libdb-5.3.28-42.el8_4.aarch64.rpm)
- [libevent-2.1.8-5.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libevent-2.1.8-5.el8.aarch64.rpm)
- [libfdisk-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libfdisk-2.32.1-47.el8_10.aarch64.rpm)
- [libffi-3.1-24.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libffi-3.1-24.el8.aarch64.rpm)
- [libgcc-8.5.0-28.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgcc-8.5.0-28.el8_10.aarch64.rpm)
- [libgcrypt-1.8.5-7.el8_6.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgcrypt-1.8.5-7.el8_6.aarch64.rpm)
- [libgpg-error-1.31-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgpg-error-1.31-1.el8.aarch64.rpm)
- [libgusb-0.3.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libgusb-0.3.0-1.el8.aarch64.rpm)
- [libicu-60.3-2.el8_1.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libicu-60.3-2.el8_1.aarch64.rpm)
- [libidn2-2.2.0-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libidn2-2.2.0-1.el8.aarch64.rpm)
- [libmodman-2.0.1-17.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libmodman-2.0.1-17.el8.aarch64.rpm)
- [libmount-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libmount-2.32.1-47.el8_10.aarch64.rpm)
- [libnghttp2-1.33.0-6.el8_10.1.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libnghttp2-1.33.0-6.el8_10.1.aarch64.rpm)
- [libnsl2-1.2.0-2.20180605git4a062cf.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libnsl2-1.2.0-2.20180605git4a062cf.el8.aarch64.rpm)
- [libpng-1.6.34-9.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpng-1.6.34-9.el8_10.aarch64.rpm)
- [libproxy-0.4.15-5.5.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libproxy-0.4.15-5.5.el8_10.aarch64.rpm)
- [libpsl-0.20.2-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpsl-0.20.2-6.el8.aarch64.rpm)
- [libpwquality-1.4.4-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libpwquality-1.4.4-6.el8.aarch64.rpm)
- [libseccomp-2.5.2-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libseccomp-2.5.2-1.el8.aarch64.rpm)
- [libsecret-0.18.6-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsecret-0.18.6-1.el8.aarch64.rpm)
- [libselinux-2.9-10.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libselinux-2.9-10.el8_10.aarch64.rpm)
- [libsemanage-2.9-12.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsemanage-2.9-12.el8_10.aarch64.rpm)
- [libsepol-2.9-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsepol-2.9-3.el8.aarch64.rpm)
- [libsigsegv-2.11-5.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsigsegv-2.11-5.el8.aarch64.rpm)
- [libsmartcols-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsmartcols-2.32.1-47.el8_10.aarch64.rpm)
- [libsoup-2.62.3-11.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libsoup-2.62.3-11.el8_10.aarch64.rpm)
- [libssh-0.9.6-16.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libssh-0.9.6-16.el8_10.aarch64.rpm)
- [libssh-config-0.9.6-16.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libssh-config-0.9.6-16.el8_10.noarch.rpm)
- [libstdc++-8.5.0-28.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libstdc++-8.5.0-28.el8_10.aarch64.rpm)
- [libtasn1-4.13-5.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libtasn1-4.13-5.el8_10.aarch64.rpm)
- [libtirpc-1.1.4-12.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libtirpc-1.1.4-12.el8_10.aarch64.rpm)
- [libunistring-0.9.9-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libunistring-0.9.9-3.el8.aarch64.rpm)
- [libusbx-1.0.23-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libusbx-1.0.23-4.el8.aarch64.rpm)
- [libutempter-1.1.6-14.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libutempter-1.1.6-14.el8.aarch64.rpm)
- [libuuid-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libuuid-2.32.1-47.el8_10.aarch64.rpm)
- [libverto-0.3.2-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libverto-0.3.2-2.el8.aarch64.rpm)
- [libxcrypt-4.1.1-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxcrypt-4.1.1-6.el8.aarch64.rpm)
- [libxml2-2.9.7-21.el8_10.3.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxml2-2.9.7-21.el8_10.3.aarch64.rpm)
- [libxslt-1.1.32-6.3.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libxslt-1.1.32-6.3.el8_10.aarch64.rpm)
- [libzstd-1.4.4-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/libzstd-1.4.4-1.el8.aarch64.rpm)
- [lz4-libs-1.8.3-5.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/l/lz4-libs-1.8.3-5.el8_10.aarch64.rpm)
- [mpfr-3.1.6-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/m/mpfr-3.1.6-1.el8.aarch64.rpm)
- [ncurses-6.1-10.20180224.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-6.1-10.20180224.el8.aarch64.rpm)
- [ncurses-base-6.1-10.20180224.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-base-6.1-10.20180224.el8.noarch.rpm)
- [ncurses-libs-6.1-10.20180224.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/ncurses-libs-6.1-10.20180224.el8.aarch64.rpm)
- [nettle-3.4.1-7.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/n/nettle-3.4.1-7.el8.aarch64.rpm)
- [openldap-2.4.46-21.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openldap-2.4.46-21.el8_10.aarch64.rpm)
- [openssl-1.1.1k-14.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-1.1.1k-14.el8_10.aarch64.rpm)
- [openssl-libs-1.1.1k-14.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-libs-1.1.1k-14.el8_10.aarch64.rpm)
- [openssl-pkcs11-0.4.10-3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/o/openssl-pkcs11-0.4.10-3.el8.aarch64.rpm)
- [p11-kit-0.23.22-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/p11-kit-0.23.22-2.el8.aarch64.rpm)
- [p11-kit-trust-0.23.22-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/p11-kit-trust-0.23.22-2.el8.aarch64.rpm)
- [pam-1.3.1-39.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pam-1.3.1-39.el8_10.aarch64.rpm)
- [pcre-8.42-6.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pcre-8.42-6.el8.aarch64.rpm)
- [pcre2-10.32-3.el8_6.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/pcre2-10.32-3.el8_6.aarch64.rpm)
- [platform-python-3.6.8-71.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-3.6.8-71.el8_10.aarch64.rpm)
- [platform-python-pip-9.0.3-24.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-pip-9.0.3-24.el8.noarch.rpm)
- [platform-python-setuptools-39.2.0-9.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/platform-python-setuptools-39.2.0-9.el8_10.noarch.rpm)
- [popt-1.18-1.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/popt-1.18-1.el8.aarch64.rpm)
- [publicsuffix-list-dafsa-20180723-1.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/publicsuffix-list-dafsa-20180723-1.el8.noarch.rpm)
- [python3-libs-3.6.8-71.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-libs-3.6.8-71.el8_10.aarch64.rpm)
- [python3-pip-wheel-9.0.3-24.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-pip-wheel-9.0.3-24.el8.noarch.rpm)
- [python3-setuptools-wheel-39.2.0-9.el8_10.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/p/python3-setuptools-wheel-39.2.0-9.el8_10.noarch.rpm)
- [readline-7.0-10.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/r/readline-7.0-10.el8.aarch64.rpm)
- [redhat-release-8.10-0.3.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/r/redhat-release-8.10-0.3.el8.aarch64.rpm)
- [sed-4.5-5.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/sed-4.5-5.el8.aarch64.rpm)
- [setup-2.12.2-9.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/setup-2.12.2-9.el8.noarch.rpm)
- [shadow-utils-4.6-23.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/shadow-utils-4.6-23.el8_10.aarch64.rpm)
- [shared-mime-info-1.9-4.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/shared-mime-info-1.9-4.el8.aarch64.rpm)
- [sqlite-libs-3.26.0-20.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/sqlite-libs-3.26.0-20.el8_10.aarch64.rpm)
- [systemd-239-82.el8_10.8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-239-82.el8_10.8.aarch64.rpm)
- [systemd-libs-239-82.el8_10.8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-libs-239-82.el8_10.8.aarch64.rpm)
- [systemd-pam-239-82.el8_10.8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/s/systemd-pam-239-82.el8_10.8.aarch64.rpm)
- [trousers-0.3.15-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/trousers-0.3.15-2.el8.aarch64.rpm)
- [trousers-lib-0.3.15-2.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/trousers-lib-0.3.15-2.el8.aarch64.rpm)
- [tzdata-2025c-1.el8.noarch](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/t/tzdata-2025c-1.el8.noarch.rpm)
- [util-linux-2.32.1-47.el8_10.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/u/util-linux-2.32.1-47.el8_10.aarch64.rpm)
- [xz-libs-5.2.4-4.el8_6.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/x/xz-libs-5.2.4-4.el8_6.aarch64.rpm)
- [zlib-1.2.11-25.el8.aarch64](https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi8/8/aarch64/baseos/os/Packages/z/zlib-1.2.11-25.el8.aarch64.rpm)

</details>



### Graphics and Display Libraries
- `libX11` - X11 client library
- `libXcomposite` - X11 Composite extension library
- `libXcursor` - X11 Cursor management library
- `libXdamage` - X11 Damage extension library
- `libXext` - X11 miscellaneous extension library
- `libXi` - X11 Input extension library
- `libXrandr` - X11 RandR extension library
- `libXtst` - X11 Testing library
- `libXss` - X11 Screen Saver extension library
- `libXScrnSaver` - X11 Screen Saver extension library
- `libdrm` - Direct Rendering Manager library
- `libxkbcommon` - Keyboard handling library
- `libxshmfence` - Shared memory fence library
- `mesa-libgbm` - Mesa Generic Buffer Management library

### Audio Libraries
- `alsa-lib` - Advanced Linux Sound Architecture library

### UI and Widget Libraries
- `atk` - Accessibility Toolkit
- `cups-libs` - Common UNIX Printing System libraries
- `gtk3` - GTK+ 3.0 graphical user interface library
- `pango` - Text layout and rendering library

### Security and Network Libraries
- `nss` - Network Security Services library

### Development Tools
- `gcc-c++` - GNU C++ compiler
- `make` - Build automation tool
- `python3` - Python 3 interpreter
- `curl` - Command-line tool for transferring data
- `wget` - Command-line tool for downloading files
- `unzip` - Archive extraction utility

### Java Runtime
- `java-21-openjdk` - OpenJDK 21 Java Runtime Environment
- `java-21-openjdk-devel` - OpenJDK 21 Development Kit

These binaries are essential for Chromium to function properly in a headless container environment. They provide the necessary system-level interfaces for graphics rendering, audio processing, input handling, and other browser operations.

## Notes

- Chromium is installed separately as a zip file (version 1194) and referenced in `playwright.config.ts` via `executablePath`
- Only Firefox and WebKit are installed from Playwright's browser bundle
- Uses Red Hat UBI 8.10 base image with OpenJDK 21 for OpenShift compatibility
- For OpenShift deployments, you may need to use `registry.redhat.io/ubi8:8.10` instead if you have proper authentication
- Ensure proper security contexts are configured for OpenShift/Kubernetes deployments
- The container runs in **headless mode by default** (configured in `playwright.config.ts`)
- Chromium runs with headless flags automatically enabled
