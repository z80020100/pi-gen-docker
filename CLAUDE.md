# Raspberry Pi OS Docker Build

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Raspberry Pi](https://img.shields.io/badge/-RaspberryPi-C51A4A?style=for-the-badge&logo=Raspberry-Pi)](https://www.raspberrypi.org/)
[![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org/)
[![ARM64](https://img.shields.io/badge/arch-ARM64-green?style=for-the-badge)](https://www.arm.com/)

Docker-based builds for creating Raspberry Pi OS ARM64 container images.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Variants](#variants)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Development](#development)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

This is the `raspios-docker` subdirectory of the pi-gen project, which provides Docker-based builds for creating Raspberry Pi OS images. This directory specifically focuses on building ARM64 (aarch64) versions of Raspberry Pi OS Lite based on Debian Bookworm using Docker containers instead of the traditional pi-gen build process.

### Key Features

- **Container-optimized**: Purpose-built for containerized deployments
- **ARM64 native**: Optimized for modern 64-bit ARM processors
- **Two variants**: Minimal (tiny) and full-featured (standard) builds
- **Docker native**: No complex build environment setup required
- **pi-gen compatible**: Follows the same build stages as traditional pi-gen

## Quick Start

### Build Tiny Version (Recommended for Containers)

```bash
./build-raspios-aarch64-lite-bookworm.sh
```

### Build Standard Version (Full Hardware Support)

```bash
./build-raspios-aarch64-lite-bookworm.sh --standard
```

### Clean Build (Remove Existing Image First)

```bash
./build-raspios-aarch64-lite-bookworm.sh --clean
```

### Run Built Image

```bash
docker run -it --rm raspios-aarch64-lite-bookworm:tiny
# or
docker run -it --rm raspios-aarch64-lite-bookworm:standard
```

## Variants

| Variant      | Description                                                       | Use Case                                          | Size   |
| ------------ | ----------------------------------------------------------------- | ------------------------------------------------- | ------ |
| **Tiny**     | Minimal container-optimized version without hardware dependencies | Containerized applications, microservices, CI/CD  | ~200MB |
| **Standard** | Complete Raspberry Pi OS Lite with full hardware support packages | IoT devices, edge computing, hardware interaction | ~500MB |

### Tiny Version Features

- Hardware-specific packages removed (GPIO, SPI, I2C, camera, Bluetooth, WiFi firmware)
- Optimized for containerized applications that don't need hardware access
- Smaller footprint and faster build times
- Perfect for cloud deployments and development

### Standard Version Features

- Complete Raspberry Pi OS Lite equivalent
- Includes all hardware support packages
- Full GPIO, camera, and wireless support
- Ideal for IoT and edge computing scenarios

## Prerequisites

- Docker installed with ARM64/aarch64 support (or running on ARM64 system)
- Sufficient disk space (builds can be 2-5 GB during build process)
- Internet connection for downloading packages

### Platform Support

| Platform              | Support        | Notes                       |
| --------------------- | -------------- | --------------------------- |
| ARM64 Linux           | ✅ Native      | Best performance            |
| macOS (Apple Silicon) | ✅ Native      | Docker required             |
| x86_64 Linux          | 🧪 Untested    | Slower build times via QEMU |
| Windows               | 🧪 Untested    | Docker with WSL2            |
| macOS (Intel)         | ❌ Unsupported | ARM64 emulation issues      |

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/RPi-Distro/pi-gen.git
   cd pi-gen/raspios-docker
   ```

2. **Make build script executable**:
   ```bash
   chmod +x build-raspios-aarch64-lite-bookworm.sh
   ```

## Usage

### Basic Commands

```bash
# Build tiny version (default)
./build-raspios-aarch64-lite-bookworm.sh

# Build standard version
./build-raspios-aarch64-lite-bookworm.sh --standard

# Clean build (removes existing image first)
./build-raspios-aarch64-lite-bookworm.sh --clean

# View help
./build-raspios-aarch64-lite-bookworm.sh --help
```

### Manual Docker Commands

```bash
# Build manually
docker build --platform linux/arm64 -t raspios-aarch64-lite-bookworm:tiny -f Dockerfile.raspios-aarch64-lite-bookworm-tiny .
docker build --platform linux/arm64 -t raspios-aarch64-lite-bookworm:standard -f Dockerfile.raspios-aarch64-lite-bookworm-standard .

# Run built images
docker run -it --rm raspios-aarch64-lite-bookworm:tiny
docker run -it --rm raspios-aarch64-lite-bookworm:standard
```

### Running with Custom Configuration

```bash
# Run with mounted volume
docker run -it --rm -v $(pwd):/workspace raspios-aarch64-lite-bookworm:tiny

# Run with specific user
docker run -it --rm --user $(id -u):$(id -g) raspios-aarch64-lite-bookworm:tiny

# Run with network access
docker run -it --rm --network host raspios-aarch64-lite-bookworm:standard
```

## Configuration

### Build Arguments

Both builds support standard pi-gen configuration through Docker build args:

| Argument           | Default         | Description                  |
| ------------------ | --------------- | ---------------------------- |
| `FIRST_USER_NAME`  | `pi`            | Default user name            |
| `FIRST_USER_PASS`  | `raspberry`     | Default user password        |
| `TIMEZONE_DEFAULT` | `Europe/London` | System timezone              |
| `LOCALE_DEFAULT`   | `en_GB.UTF-8`   | System locale                |
| `TARGET_HOSTNAME`  | `raspberrypi`   | System hostname              |
| `ENABLE_SSH`       | `1`             | Enable SSH service           |
| `APT_PROXY`        | -               | APT proxy server             |
| `TEMP_REPO`        | -               | Temporary package repository |

### Custom Build Example

```bash
docker build --platform linux/arm64 \
  --build-arg FIRST_USER_NAME=myuser \
  --build-arg FIRST_USER_PASS=mypassword \
  --build-arg TARGET_HOSTNAME=myraspios \
  --build-arg TIMEZONE_DEFAULT=America/New_York \
  --build-arg LOCALE_DEFAULT=en_US.UTF-8 \
  -t my-raspios:custom \
  -f Dockerfile.raspios-aarch64-lite-bookworm-tiny .
```

## Architecture

### Build Process Alignment

Both Dockerfiles follow the exact pi-gen build stages:

- **Stage 0**: Bootstrap base Debian system using debootstrap
- **Stage 1**: Basic system configuration (boot files, users, networking)
- **Stage 2**: Complete system packages and configuration
- **Export Stage**: Final cleanup and container preparation

### Container Adaptations

The Dockerfiles make minimal adaptations for container environments:

- Download GPG keys instead of using local files
- Handle hardware service masking for container compatibility
- Skip hardware-dependent initialization (boot partitions, device tree, etc.)
- Use static DNS resolution instead of dynamic DHCP
- Optimize for container layer caching

### File Structure

```
raspios-docker/
├── README.md                                    # This file
├── CLAUDE.md                                    # Development guide
├── build-raspios-aarch64-lite-bookworm.sh      # Main build script
├── Dockerfile.raspios-aarch64-lite-bookworm-tiny      # Minimal variant
└── Dockerfile.raspios-aarch64-lite-bookworm-standard  # Standard variant
```

## Development

### Building for Development

```bash
# Build with no cache for testing changes
docker build --platform linux/arm64 --no-cache -t raspios-test -f Dockerfile.raspios-aarch64-lite-bookworm-tiny .

# Build with specific stages for debugging
docker build --platform linux/arm64 --target stage1 -t raspios-debug -f Dockerfile.raspios-aarch64-lite-bookworm-tiny .
```

### Testing Images

```bash
# Quick functionality test
docker run --rm raspios-aarch64-lite-bookworm:tiny uname -a
docker run --rm raspios-aarch64-lite-bookworm:tiny cat /etc/os-release

# Interactive testing
docker run -it --rm raspios-aarch64-lite-bookworm:tiny bash
```

### Performance Monitoring

```bash
# Monitor build progress
docker build --platform linux/arm64 --progress=plain -t raspios-aarch64-lite-bookworm:tiny -f Dockerfile.raspios-aarch64-lite-bookworm-tiny .

# Check image size
docker images raspios-aarch64-lite-bookworm
```

## Troubleshooting

### Common Issues

#### Build Fails with Permission Errors

- Ensure Docker daemon is running and user has Docker access
- On Linux: Add user to docker group: `sudo usermod -aG docker $USER`

#### ARM64 Builds on x86 Systems

- Ensure Docker Desktop has ARM64 emulation enabled
- Install QEMU emulation: `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes`

#### Disk Space Issues

- Large builds may require increasing Docker's disk space allocation
- Clean up unused images: `docker system prune -a`
- Monitor disk usage: `docker system df`

#### Network Issues During Build

- If behind corporate firewall, configure APT_PROXY build argument
- Check DNS resolution: `docker run --rm raspios-aarch64-lite-bookworm:tiny nslookup google.com`

#### Slow Build Performance

- Use `--build-arg BUILDKIT_INLINE_CACHE=1` for better caching
- Consider building on ARM64 hardware for better performance
- Use local package mirrors with TEMP_REPO argument

### Debug Commands

```bash
# Check container contents
docker run --rm raspios-aarch64-lite-bookworm:tiny ls -la /

# Inspect image layers
docker history raspios-aarch64-lite-bookworm:tiny

# Container resource usage
docker stats

# Build with verbose output
./build-raspios-aarch64-lite-bookworm.sh 2>&1 | tee build.log
```

## Integration with Main pi-gen Project

This is a specialized Docker build system within the larger [pi-gen project](https://github.com/RPi-Distro/pi-gen). The parent project contains the traditional image building system with stage-based directory structure, while this subdirectory provides containerized alternatives.

### Key Differences from Traditional pi-gen

| Aspect          | Traditional pi-gen          | Docker Build                |
| --------------- | --------------------------- | --------------------------- |
| **Environment** | Host system setup required  | Container-based, isolated   |
| **Platform**    | Raspberry Pi hardware or VM | Any Docker-capable platform |
| **Output**      | SD card images              | Docker container images     |
| **Use Case**    | Physical device deployment  | Container orchestration     |

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit with descriptive messages: `git commit -m "Add feature description"`
5. Push to your fork: `git push origin feature-name`
6. Create a Pull Request

### Development Guidelines

- Test both tiny and standard variants
- Ensure builds work on multiple platforms
- Update documentation for any new features
- Follow existing code style and conventions
- Add appropriate error handling

## Related Projects

- [Main pi-gen project](https://github.com/RPi-Distro/pi-gen) - Traditional Raspberry Pi OS image building
- [Raspberry Pi OS Documentation](https://www.raspberrypi.org/documentation/)
- [Docker Multi-arch Documentation](https://docs.docker.com/desktop/multi-arch/)

## License

This project is licensed under the BSD 3-Clause License, the same as the original pi-gen project. See the [LICENSE](LICENSE) file for details.

Based on [pi-gen](https://github.com/RPi-Distro/pi-gen) project.
