#!/usr/bin/env bash

set -e

mkdir -p build

echo "Building sucata for Linux x64, Linux Arm, Mac x64 and Mac Arm..."

odin build . -out:build/sucata-macos-arm64

#odin build . -out:build/sucata-macos-amd64 -target:darwin_amd64

odin build . \
  -target:linux_amd64 \
  -out:build/sucata-linux-amd64 \
  -extra-linker-flags:"-fuse-ld=lld"

odin build . \
  -target:linux_arm64 \
  -out:build/sucata-linux-arm64 \
  -extra-linker-flags:"-fuse-ld=lld"

echo "Sucata builded with success"