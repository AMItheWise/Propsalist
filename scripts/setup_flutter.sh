#!/usr/bin/env bash
set -e

# Versions
FLUTTER_VERSION=3.35.7
FLUTTER_CHANNEL=stable

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
  curl git unzip xz-utils zip libglu1-mesa

# Download Flutter
cd $HOME
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz

# Extract
tar xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz

# Add to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/flutter/bin:$PATH"

# Precache binaries
flutter doctor
flutter precache

# Enable platforms
flutter config --enable-web
