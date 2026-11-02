#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gnupg dirmngr python3 xz-utils

readonly METADATA_URL="https://aus1.torproject.org/torbrowser/update_3/release/downloads.json"
readonly KEY_FINGERPRINT="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"

metadata=$(curl -fsSL "$METADATA_URL")
read -r version archive_url sig_url < <(python3 -c '
import json
import sys

data = json.load(sys.stdin)
entry = data["downloads"]["linux-x86_64"]["ALL"]
print(data["version"], entry["binary"], entry["sig"])
' <<< "$metadata")
echo "Installing Tor Browser $version from $archive_url"

archive=$(basename "$archive_url")
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
export GNUPGHOME="$work_dir/gnupg"
mkdir -m 0700 "$GNUPGHOME"

# Tor Project's documented method: fetch the key via Web Key Directory on torproject.org
gpg --batch --auto-key-locate clear,nodefault,wkd --locate-keys torbrowser@torproject.org
if ! gpg --batch --with-colons --fingerprint "$KEY_FINGERPRINT" | grep -q "^fpr:::::::::${KEY_FINGERPRINT}:"; then
    echo "Tor Browser signing key $KEY_FINGERPRINT was not imported" >&2
    exit 1
fi

curl -fsSL "$archive_url" -o "$work_dir/$archive"
curl -fsSL "$sig_url" -o "$work_dir/$archive.asc"
gpg --batch --status-fd 1 --verify "$work_dir/$archive.asc" "$work_dir/$archive" > "$work_dir/verify.status"
if ! awk -v fp="$KEY_FINGERPRINT" '$2 == "VALIDSIG" && $NF == fp { ok = 1 } END { exit !ok }' "$work_dir/verify.status"; then
    echo "Archive signature was not made by the pinned Tor Browser signing key" >&2
    exit 1
fi

mkdir -p /opt
tar -xJf "$work_dir/$archive" -C /opt
test -x /opt/tor-browser/Browser/start-tor-browser
test -d /opt/tor-browser/Browser/TorBrowser/Data/Browser/profile.default

cat > /opt/tor-browser/Browser/TorBrowser/Data/Browser/profile.default/user.js <<'EOF'
user_pref("extensions.torbutton.security_slider", 1);
EOF

cat > /usr/local/bin/tor-browser <<'EOF'
#!/usr/bin/env bash
exec /opt/tor-browser/Browser/start-tor-browser --detach "$@"
EOF
chmod 755 /usr/local/bin/tor-browser
chown -R 1000:0 /opt/tor-browser

update-alternatives --install /usr/bin/x-www-browser \
    x-www-browser /usr/local/bin/tor-browser 300
update-alternatives --set x-www-browser /usr/local/bin/tor-browser

cat > /usr/share/applications/tor-browser.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Tor Browser
Exec=/usr/local/bin/tor-browser %u
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

mkdir -p "$HOME/.config"
cat > "$HOME/.config/mimeapps.list" <<'EOF'
[Default Applications]
text/html=tor-browser.desktop
application/xhtml+xml=tor-browser.desktop
x-scheme-handler/http=tor-browser.desktop
x-scheme-handler/https=tor-browser.desktop
EOF

apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
