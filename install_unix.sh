#!/usr/bin/env bash

set -e

echo "Installing sucata..."

if ! command -v unzip >/dev/null && ! command -v 7z >/dev/null; then
  echo "Error: Needs unzip or 7z to install Sucata"
  exit 1
fi

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS" == "Darwin" ]]; then
  if [[ "$ARCH" == "arm64" ]]; then
    TARGET="sucata-osx-arm"
  elif [[ "$ARCH" == "x86_64" ]]; then
    TARGET="sucata-osx-amd"
  else
    echo "ERROR: Unsupported macOS architecture: $ARCH"
    exit 1
  fi
elif [[ "$OS" == "Linux" ]]; then
  if [[ "$ARCH" == "x86_64" ]]; then
    TARGET="sucata-linux-amd"
  elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    TARGET="sucata-linux-arm"
  else
    echo "ERROR: Unsupported Linux architecture: $ARCH"
    exit 1
  fi
else
  echo "ERROR: Unsupported operating system: $OS"
  exit 1
fi

SUCATA_VERSION="0.1.1"
SUCATA_BIN="sucata"
SUCATA_URL="https://github.com/gumpdev/sucata/releases/download/$SUCATA_VERSION/$TARGET.zip"
SUCATA_DIR="$HOME/sucata"
SUCATA_TEMP_ZIP="$SUCATA_DIR/temp.zip"
SUCATA_BIN="$SUCATA_DIR/$SUCATA_BIN"
SUCATA_BIN_LINK="$HOME/.local/bin/sucata"

mkdir -p "$SUCATA_DIR"

curl --fail --location --progress-bar --output "$SUCATA_TEMP_ZIP" "$SUCATA_URL"
if command -v unzip >/dev/null; then
	unzip -d "$SUCATA_DIR" -o "$SUCATA_TEMP_ZIP" >/dev/null
else
	7z x -o"$SUCATA_DIR" -y "$SUCATA_TEMP_ZIP" >/dev/null
fi

chmod +x "$SUCATA_BIN"
ln -sf "$SUCATA_BIN" "$SUCATA_BIN_LINK"
echo "Sucata installed on $SUCATA_BIN"

LINE='export PATH="$SUCATA_DIR:$PATH"'
SHELL_NAME="$(basename "$SHELL")"

add_to_file() {
  local file="$1"
  local line="$2"

  if [ -f "$file" ]; then
      if ! grep -qxF "$line" "$file"; then
          echo "$line" >> "$file"
      fi
  else
      echo "$line" >> "$file"
  fi
}

case "$SHELL_NAME" in
    bash)
        add_to_file "$HOME/.bashrc" "$LINE"
        echo "Added PATH to $HOME/.bashrc"
        ;;
    zsh)
        add_to_file "$HOME/.zshrc" "$LINE"
        echo "Added PATH to $HOME/.zshrc"
        ;;
    *)
        echo "Shell not supported: $SHELL_NAME"
        echo "Please add manually to PATH."
        ;;
esac