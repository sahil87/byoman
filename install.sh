#!/bin/sh
set -e

# byoman installer
# Usage: curl -sSfL https://raw.githubusercontent.com/sahil87/byoman/main/install.sh | sh

REPO="sahil87/byoman"
BINARY="byoman"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    darwin|linux) ;;
    mingw*|msys*|cygwin*)
        echo "Error: Windows is not supported by this installer."
        echo "Please download manually from https://github.com/$REPO/releases"
        exit 1
        ;;
    *)
        echo "Error: Unsupported OS: $OS"
        exit 1
        ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get latest version from GitHub API
echo "Fetching latest release..."
if command -v curl >/dev/null 2>&1; then
    VERSION=$(curl -sSf "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
elif command -v wget >/dev/null 2>&1; then
    VERSION=$(wget -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
else
    echo "Error: curl or wget is required"
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "Error: Could not determine latest version"
    exit 1
fi

# Remove 'v' prefix for archive naming
VERSION_NUM="${VERSION#v}"

# Construct download URL
ARCHIVE="${BINARY}_${VERSION_NUM}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
CHECKSUM_URL="https://github.com/$REPO/releases/download/$VERSION/checksums.txt"

echo "Installing $BINARY $VERSION for $OS/$ARCH..."

# Create temp directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

# Download archive and checksums
echo "Downloading $URL..."
if command -v curl >/dev/null 2>&1; then
    curl -sSfLO "$URL"
    curl -sSfLO "$CHECKSUM_URL"
else
    wget -q "$URL"
    wget -q "$CHECKSUM_URL"
fi

# Verify checksum
echo "Verifying checksum..."
if command -v sha256sum >/dev/null 2>&1; then
    grep "$ARCHIVE" checksums.txt | sha256sum -c - >/dev/null 2>&1
elif command -v shasum >/dev/null 2>&1; then
    grep "$ARCHIVE" checksums.txt | shasum -a 256 -c - >/dev/null 2>&1
else
    echo "Warning: Could not verify checksum (sha256sum/shasum not found)"
fi

# Extract
echo "Extracting..."
tar -xzf "$ARCHIVE"

# Install
echo "Installing to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY" "$INSTALL_DIR/"
else
    sudo mv "$BINARY" "$INSTALL_DIR/"
fi

echo ""
echo "Successfully installed $BINARY $VERSION to $INSTALL_DIR/$BINARY"
echo "Run '$BINARY --version' to verify the installation."
