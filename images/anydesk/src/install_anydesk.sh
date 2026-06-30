#!/usr/bin/env bash
# Install AnyDesk
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates gnupg

# ── AnyDesk (official apt repo) ───────────────────────────────
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
    | gpg --dearmor -o /usr/share/keyrings/anydesk-archive-keyring.gpg
chmod go+r /usr/share/keyrings/anydesk-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main" \
    > /etc/apt/sources.list.d/anydesk-stable.list

apt-get update

# Stub systemctl so AnyDesk post-install doesn't fail in Docker
# (the post-install script tries to 'systemctl start anydesk', which has no init system)
cat > /usr/local/bin/systemctl << 'SH'
#!/bin/bash
exit 0
SH
chmod +x /usr/local/bin/systemctl

apt-get install -y anydesk

# Remove the stub
rm -f /usr/local/bin/systemctl

# Copy the desktop icon to the profile desktop
DESKTOP_FILE=$(find /usr/share/applications -iname "anydesk*.desktop" 2>/dev/null | head -1 || true)
if [ -n "$DESKTOP_FILE" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")"
fi

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \; 2>/dev/null || true
chown -R 1000:0 "$HOME"
