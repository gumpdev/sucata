#!/usr/bin/env bash

set -e

echo "==========================="
echo "  Sucata Installer (Unix)  "
echo "==========================="
echo

SUCATA_BIN="sucata"

INSTALL_DIR="$HOME/.local/sucata"
BIN_DIR="$HOME/.local/bin"
LINK_PATH="$BIN_DIR/sucata"

OS=$(uname -s)
ARCH=$(uname -m)

echo "Detecting system..."
echo "OS: $OS"
echo "Architecture: $ARCH"
echo

if [[ "$OS" == "Darwin" ]]; then
  if [[ "$ARCH" == "arm64" ]]; then
    TARGET="darwin_arm64"
    echo "Detected: Apple Silicon (M1/M2/M3)"
  elif [[ "$ARCH" == "x86_64" ]]; then
    TARGET="darwin_amd64"
    echo "Detected: Apple Intel"
  else
    echo "ERROR: Unsupported macOS architecture: $ARCH"
    exit 1
  fi
elif [[ "$OS" == "Linux" ]]; then
  if [[ "$ARCH" == "x86_64" ]]; then
    TARGET="linux_amd64"
    echo "Detected: Linux x86_64"
  elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    TARGET="linux_arm64"
    echo "Detected: Linux ARM64"
  else
    echo "ERROR: Unsupported Linux architecture: $ARCH"
    exit 1
  fi
else
  echo "ERROR: Unsupported operating system: $OS"
  exit 1
fi

echo
echo "Building Sucata for target: $TARGET"
echo

odin build . -out:sucata -target:$TARGET

if [[ ! -f "$SUCATA_BIN" ]]; then
  echo "ERROR: Build failed. File '$SUCATA_BIN' not found after compilation."
  exit 1
fi

echo "Build successful!"
echo

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

echo "Copying files..."
cp "$SUCATA_BIN" "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/$SUCATA_BIN"

if [[ -L "$LINK_PATH" || -f "$LINK_PATH" ]]; then
  rm -f "$LINK_PATH"
fi

ln -s "$INSTALL_DIR/$SUCATA_BIN" "$LINK_PATH"

echo
echo "Installation complete!"
echo "Files installed to: $INSTALL_DIR"
echo "Symlink created at: $LINK_PATH"
echo

echo "If '~/.local/bin' is not in your PATH, add this line to your shell config:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo "for example in ~/.bashrc, ~/.zshrc, etc."
echo
echo "After that, you can run the program simply by typing: sucata"
