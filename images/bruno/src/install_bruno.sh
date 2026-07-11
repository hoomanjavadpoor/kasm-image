#!/usr/bin/env bash
# Install Bruno
set -ex

export DEBIAN_FRONTEND=noninteractive

BRUNO_VERSION="3.5.1"
BRUNO_DEB="bruno_${BRUNO_VERSION}_amd64_linux.deb"
BRUNO_URL="https://github.com/usebruno/bruno/releases/download/v${BRUNO_VERSION}/${BRUNO_DEB}"

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libasound2 \
    libatspi2.0-0 \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libsecret-1-0 \
    libuuid1 \
    libxss1 \
    libxtst6 \
    xdg-utils

curl -fsSL "$BRUNO_URL" -o "/tmp/${BRUNO_DEB}"
apt-get install -y "/tmp/${BRUNO_DEB}"

DESKTOP_FILE=$(find /usr/share/applications -iname "bruno*.desktop" 2>/dev/null | head -1 || true)
if [ -n "$DESKTOP_FILE" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")"
fi

apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \; 2>/dev/null || true
chown -R 1000:0 "$HOME"
