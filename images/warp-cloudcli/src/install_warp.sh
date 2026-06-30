#!/usr/bin/env bash
# Install Warp Terminal
# Download URL: GET https://app.warp.dev/download?package=deb serves the binary
# directly (despite HEAD returning text/html — the GET works correctly).
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Runtime dependencies (from .deb Depends field + software rendering) ──
apt-get update
apt-get install -y --no-install-recommends \
    curl ca-certificates \
    fontconfig \
    libegl1 \
    libwayland-client0 \
    libwayland-egl1 \
    libx11-6 \
    libxcb1 \
    libxcursor1 \
    libxi6 \
    libxkbcommon-x11-0 \
    libxkbcommon0 \
    zlib1g \
    libgl1-mesa-dri \
    libglx-mesa0

# ── Download and install Warp ─────────────────────────────────
curl -fsSL "https://app.warp.dev/download?package=deb" -o /tmp/warp.deb
dpkg -i /tmp/warp.deb || apt-get install -f -y --no-install-recommends

# Remove the defunct apt repo that postinst writes (avoids apt warnings)
rm -f /etc/apt/sources.list.d/warpdotdev.list \
      /etc/apt/sources.list.d/warpdotdev.sources \
      /etc/apt/trusted.gpg.d/warpdotdev.gpg 2>/dev/null || true

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
