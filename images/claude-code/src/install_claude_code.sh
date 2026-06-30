#!/usr/bin/env bash
# Install Claude Desktop (Anthropic)
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Dependencies for Electron-based desktop app ────────────────
apt-get update
apt-get install -y --no-install-recommends \
    curl ca-certificates \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    libgbm1 \
    libsecret-1-0 \
    xdg-utils

# ── Download and install Claude Desktop ────────────────────────
# Always fetches the latest release via the official redirect
curl -fsSL \
    "https://claude.ai/api/claude-for-desktop/download?platform=linux_deb" \
    -o /tmp/claude-desktop.deb
apt-get install -y /tmp/claude-desktop.deb

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
