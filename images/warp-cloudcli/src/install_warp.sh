#!/usr/bin/env bash
# Install xfce4-terminal + cloud CLIs (replaces Warp Terminal which no longer
# distributes a Linux build as of mid-2026).
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends xfce4-terminal

# ── Shell profile: welcome banner ─────────────────────────────
cat >> /etc/bash.bashrc <<'BASHRC'

# ── Cloud CLIs Terminal workspace ─────────────────────────────
if [ -t 1 ]; then
  echo ""
  printf '\033[1;32m  ╔══════════════════════════════════════════╗\n'
  printf '\033[1;32m  ║      \033[1;37mCloud CLIs Terminal Workspace\033[1;32m    ║\n'
  printf '\033[1;32m  ╠══════════════════════════════════════════╣\n'
  printf '\033[1;32m  ║  \033[0;37maz\033[0m      Azure CLI                      \033[1;32m║\n'
  printf '\033[1;32m  ║  \033[0;37maws\033[0m     AWS CLI                        \033[1;32m║\n'
  printf '\033[1;32m  ║  \033[0;37mgcloud\033[0m  Google Cloud CLI                \033[1;32m║\n'
  printf '\033[1;32m  ║  \033[0;37mgh\033[0m      GitHub CLI                     \033[1;32m║\n'
  printf '\033[1;32m  ║  \033[0;37mkubectl\033[0m Kubernetes CLI                 \033[1;32m║\n'
  printf '\033[1;32m  ╚══════════════════════════════════════════╝\n'
  printf '\033[0m\n'
fi
BASHRC

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
