#!/usr/bin/env bash
# Install Lens Desktop (Kubernetes IDE), kubectl, and helm
# Following: https://docs.k8slens.dev/k8slens/getting-started/install-lens/#install-lens-desktop-from-the-apt-repository
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates gnupg

# ── Lens Desktop (official apt repository) ────────────────────
# Step 1: add the Lens GPG key
curl -fsSL https://downloads.k8slens.dev/keys/gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null

# Step 2: add the apt repo
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" \
    > /etc/apt/sources.list.d/lens.list

# Step 3: install
apt-get update
apt-get install -y lens

# Copy .desktop icon to the profile desktop
DESKTOP_FILE=$(find /usr/share/applications -iname "lens*.desktop" 2>/dev/null | head -1 || true)
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
