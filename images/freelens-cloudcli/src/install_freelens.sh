#!/usr/bin/env bash
# Install FreeLens (open-source Kubernetes IDE) and Helm
# Releases: https://github.com/freelensapp/freelens/releases
# Asset pattern: Freelens-X.X.X-linux-amd64.deb
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates

# ── FreeLens (latest GitHub release) ─────────────────────────
FREELENS_URL=$(curl -fsSL https://api.github.com/repos/freelensapp/freelens/releases/latest \
    | grep '"browser_download_url"' \
    | grep 'linux-amd64\.deb"' \
    | head -1 \
    | cut -d'"' -f4)

if [ -z "$FREELENS_URL" ]; then
    echo "ERROR: Could not resolve FreeLens .deb download URL" >&2
    exit 1
fi

curl -fsSL "$FREELENS_URL" -o /tmp/freelens.deb
apt-get install -y /tmp/freelens.deb
rm /tmp/freelens.deb

# Copy .desktop icon to the profile desktop
DESKTOP_FILE=$(find /usr/share/applications -iname "freelens*.desktop" 2>/dev/null | head -1 || true)
if [ -n "$DESKTOP_FILE" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")"
fi

# ── Helm ──────────────────────────────────────────────────────
# (kubectl is installed with autocompletion by shared/scripts/install_cloudclis.sh)
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \; 2>/dev/null || true
chown -R 1000:0 "$HOME"
