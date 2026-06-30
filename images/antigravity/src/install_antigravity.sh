#!/usr/bin/env bash
# Install Google Antigravity Hub desktop app
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Dependencies for Electron-based Linux desktop app ─────────
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
    xdg-utils \
    libcurl4

# ── Download and install Antigravity Hub ───────────────────────
ANTIGRAVITY_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.2.1-5287492581195776/linux-x64/Antigravity.tar.gz"

curl -fsSL "$ANTIGRAVITY_URL" -o /tmp/Antigravity.tar.gz
mkdir -p /opt/antigravity
tar -xzf /tmp/Antigravity.tar.gz -C /opt/antigravity

# Locate the main executable — case-insensitive to handle 'antigravity' vs 'Antigravity'
ANTIGRAVITY_BIN=$(find /opt/antigravity -maxdepth 2 -iname 'antigravity' -type f | head -1)
if [ -z "$ANTIGRAVITY_BIN" ]; then
    # Fallback: first executable in the extracted tree (exclude chrome-sandbox)
    ANTIGRAVITY_BIN=$(find /opt/antigravity -maxdepth 2 -type f -perm /u+x ! -name 'chrome-sandbox' | head -1)
fi
chmod +x "$ANTIGRAVITY_BIN"
ln -sf "$ANTIGRAVITY_BIN" /usr/local/bin/antigravity
echo "Linked: $ANTIGRAVITY_BIN -> /usr/local/bin/antigravity"

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
