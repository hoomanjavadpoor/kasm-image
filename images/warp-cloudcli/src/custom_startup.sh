#!/usr/bin/env bash
# Kasm custom_startup.sh – Warp Terminal + cloud CLIs
set -ex

PGREP="warp"
export MAXIMIZE="true"
export MAXIMIZE_NAME="Warp"
MAXIMIZE_SCRIPT=$STARTUPDIR/maximize_window.sh

launch_app() {
    # LIBGL_ALWAYS_SOFTWARE forces Mesa llvmpipe (software renderer) so Warp's
    # wgpu/EGL renderer works in VNC containers without a physical GPU.
    LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe \
        warp-terminal
}

options=$(getopt -o gau: -l go,assign,url: -n "$0" -- "$@") || exit
eval set -- "$options"

while [[ $1 != -- ]]; do
    case $1 in
        -g|--go)     GO='true';     shift 1 ;;
        -a|--assign) ASSIGN='true'; shift 1 ;;
        -u|--url)    OPT_URL=$2;    shift 2 ;;
        *) echo "bad option: $1" >&2; exit 1 ;;
    esac
done
shift

for arg; do echo "arg! $arg"; done
FORCE=$2

kasm_exec() {
    /usr/bin/filter_ready
    /usr/bin/desktop_ready
    bash "${MAXIMIZE_SCRIPT}" &
    launch_app
}

kasm_startup() {
    if [ -z "$DISABLE_CUSTOM_STARTUP" ] || [ -n "$FORCE" ]; then
        echo "Entering process startup loop"
        set +x
        while true; do
            if ! pgrep -x "$PGREP" > /dev/null; then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                bash "${MAXIMIZE_SCRIPT}" &
                launch_app &
                set -e
            fi
            sleep 1
        done
        set -x
    fi
}

if [ -n "$GO" ] || [ -n "$ASSIGN" ]; then
    kasm_exec
else
    kasm_startup
fi
