#!/usr/bin/env bash
# Install Firefox (native .deb via Mozilla's apt repo, not snap) and set as
# the default browser so apps can open login/auth URLs via xdg-open.
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Mozilla official apt repo ──────────────────────────────────
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
    -o /etc/apt/keyrings/packages.mozilla.org.asc

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] \
https://packages.mozilla.org/apt mozilla main" \
    > /etc/apt/sources.list.d/mozilla.list

# Pin Mozilla repo above Ubuntu's snap-redirect package
cat > /etc/apt/preferences.d/mozilla-firefox <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

apt-get update
apt-get install -y --no-install-recommends firefox

# ── Set Firefox as the system default browser ──────────────────
update-alternatives --install /usr/bin/x-www-browser \
    x-www-browser /usr/bin/firefox 200
update-alternatives --set x-www-browser /usr/bin/firefox

# XDG mime defaults (written to the profile home; copied at image layer time)
mkdir -p "$HOME/.config"
cat > "$HOME/.config/mimeapps.list" <<'EOF'
[Default Applications]
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop

[Added Associations]
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
EOF

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
