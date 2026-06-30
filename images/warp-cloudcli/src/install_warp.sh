#!/usr/bin/env bash
# Install Warp Terminal
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg apt-transport-https

# ── Warp Terminal (official apt repo) ─────────────────────────
curl -fsSL https://releases.warp.dev/linux/keys/warp.asc \
    | gpg --dearmor -o /usr/share/keyrings/warp-archive-keyring.gpg
chmod go+r /usr/share/keyrings/warp-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/warp-archive-keyring.gpg] https://releases.warp.dev/linux/deb stable main" \
    > /etc/apt/sources.list.d/warp.list

apt-get update
apt-get install -y warp-terminal

# Fallback: if apt install fails, download the .deb directly
if ! command -v warp-terminal &>/dev/null; then
    echo "apt install failed, falling back to direct .deb download"
    curl -fsSL "https://app.warp.dev/download?package=deb" \
        -L -o /tmp/warp.deb
    apt-get install -y /tmp/warp.deb
    rm /tmp/warp.deb
fi

# Create a desktop shortcut
DESKTOP_FILE=$(find /usr/share/applications -iname "warp*.desktop" 2>/dev/null | head -1 || true)
if [ -n "$DESKTOP_FILE" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")"
fi

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \; 2>/dev/null || true
chown -R 1000:0 "$HOME"
