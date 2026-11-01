#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gnupg python3 xz-utils

readonly BASE_URL="https://dist.torproject.org/torbrowser"
readonly KEY_URL="https://keys.openpgp.org/vks/v1/by-fingerprint/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"
readonly KEY_FINGERPRINT="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"

release_index=$(curl -fsSL "$BASE_URL/")
version=$(python3 -c '
import re
import sys

versions = re.findall(r"""href=["\x27](\d+\.\d+(?:\.\d+)?)/["\x27]""", sys.stdin.read())
if not versions:
    raise SystemExit("No stable Tor Browser releases found in the official release index")
print(max(versions, key=lambda version: tuple(map(int, version.split(".")))))
' <<< "$release_index")

archive="tor-browser-linux-x86_64-${version}.tar.xz"
release_url="${BASE_URL}/${version}"
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
export GNUPGHOME="$work_dir/gnupg"
mkdir -m 0700 "$GNUPGHOME"

curl -fsSL "$KEY_URL" -o "$work_dir/tor-browser-signing-key.asc"
gpg --batch --import "$work_dir/tor-browser-signing-key.asc"
imported_fingerprint=$(gpg --batch --with-colons --fingerprint \
    | awk -F: '$1 == "fpr" { print $10; exit }')
if [[ "$imported_fingerprint" != "$KEY_FINGERPRINT" ]]; then
    echo "Unexpected Tor Browser signing key fingerprint: $imported_fingerprint" >&2
    exit 1
fi

curl -fsSL "$release_url/$archive" -o "$work_dir/$archive"
curl -fsSL "$release_url/$archive.asc" -o "$work_dir/$archive.asc"
gpg --batch --verify "$work_dir/$archive.asc" "$work_dir/$archive"

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
