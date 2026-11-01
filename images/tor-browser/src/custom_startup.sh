#!/usr/bin/env bash
set -e

browser_running() {
    pgrep -u "$(id -u)" -f '/opt/tor-browser/Browser/firefox' >/dev/null
}

launch_browser() {
    /usr/local/bin/tor-browser
}

if [[ -n "${DISABLE_CUSTOM_STARTUP:-}" ]]; then
    exit 0
fi

echo "Starting Tor Browser workspace"
while true; do
    if ! browser_running; then
        /usr/bin/filter_ready
        /usr/bin/desktop_ready
        launch_browser &
    fi
    sleep 2
done
