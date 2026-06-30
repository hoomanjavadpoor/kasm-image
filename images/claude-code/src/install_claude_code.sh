#!/usr/bin/env bash
# Install Node.js LTS, Anthropic Claude Code CLI, and xterm
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates xterm

# ── Node.js LTS ────────────────────────────────────────────────
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# ── Claude Code CLI ────────────────────────────────────────────
npm install -g @anthropic-ai/claude-code

# ── Shell profile: welcome banner ─────────────────────────────
cat >> /etc/bash.bashrc <<'BASHRC'

# ── Claude Code workspace ──────────────────────────────────────
if [ -t 1 ]; then
  echo ""
  printf '\033[1;33m  ╔══════════════════════════════════════════╗\n'
  printf '\033[1;33m  ║     \033[1;37mAnthropic Claude Code Workspace\033[1;33m  ║\n'
  printf '\033[1;33m  ╠══════════════════════════════════════════╣\n'
  printf '\033[1;33m  ║  \033[0;37mRun:\033[0m  claude                          \033[1;33m║\n'
  printf '\033[1;33m  ║  \033[0;37mAuth:\033[0m export ANTHROPIC_API_KEY=sk-ant- \033[1;33m║\n'
  printf '\033[1;33m  ║  \033[0;37mGH:\033[0m   gh auth login                   \033[1;33m║\n'
  printf '\033[1;33m  ╚══════════════════════════════════════════╝\n'
  printf '\033[0m\n'
fi
BASHRC

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
