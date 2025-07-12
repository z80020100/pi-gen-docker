#!/bin/bash
# Raspberry Pi OS Docker Build Script
# Version: 0.1

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BUILD_TYPE="tiny"

usage() {
    echo -e "${BLUE}Raspberry Pi OS Docker Build Script v0.1${NC}"
    echo "Usage: $0 [-s|--standard] [-c|--clean] [-h|--help]"
    echo -e "  ${YELLOW}-s, --standard${NC}  Build standard version (default: tiny)"
    echo -e "  ${YELLOW}-c, --clean${NC}     Remove existing image first"
    echo -e "  ${YELLOW}-h, --help${NC}      Show this help"
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -s | --standard)
        BUILD_TYPE="standard"
        shift
        ;;
    -c | --clean)
        CLEAN_BUILD=true
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        usage
        exit 1
        ;;
    esac
done

if [ "$BUILD_TYPE" = "standard" ]; then
    DOCKERFILE="Dockerfile.raspios-aarch64-lite-bookworm-standard"
    IMAGE_TAG="standard"
else
    DOCKERFILE="Dockerfile.raspios-aarch64-lite-bookworm-tiny"
    IMAGE_TAG="tiny"
fi

IMAGE_NAME="raspios-aarch64-lite-bookworm"

if [ ! -f "$DOCKERFILE" ]; then
    echo -e "${RED}Error: $DOCKERFILE not found${NC}"
    exit 1
fi

if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning existing image...${NC}"
    docker rmi "${IMAGE_NAME}:${IMAGE_TAG}" 2>/dev/null || true
fi

echo -e "${BLUE}Building ${IMAGE_NAME}:${IMAGE_TAG}...${NC}"
docker build --platform linux/arm64 -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${DOCKERFILE}" .

echo -e "${GREEN}✓ Build completed: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
echo -e "${BLUE}Run with:${NC} docker run -it --rm ${IMAGE_NAME}:${IMAGE_TAG}"
