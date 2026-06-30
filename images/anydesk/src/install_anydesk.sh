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

# Download and unpack without running post-install scripts.
# AnyDesk 8.x post-install calls system operations (systemctl, sysctl, dmesg)
# that are not permitted inside an unprivileged Docker build container.
cd /tmp
apt-get download anydesk
dpkg --unpack anydesk_*.deb
# Delete the post-install script before dpkg --configure runs it
rm -f /var/lib/dpkg/info/anydesk.postinst
# Mark the package as configured (no postinst → succeeds cleanly)
dpkg --configure anydesk
cd /

# Copy the desktop icon to the profile desktop
DESKTOP_FILE=$(find /usr/share/applications -iname "anydesk*.desktop" 2>/dev/null | head -1 || true)
if [ -n "$DESKTOP_FILE" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")"
fi

# ── Cleanup ────────────────────────────────────────────────────
rm -f /tmp/anydesk_*.deb
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \; 2>/dev/null || true
chown -R 1000:0 "$HOME"
