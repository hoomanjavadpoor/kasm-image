#!/usr/bin/env bash
# Install Node.js LTS, OpenAI Codex CLI, and xterm
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates xterm

# ── Node.js LTS ────────────────────────────────────────────────
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# ── OpenAI Codex CLI ───────────────────────────────────────────
npm install -g @openai/codex

# ── Shell profile: welcome banner ─────────────────────────────
cat >> /etc/bash.bashrc <<'BASHRC'

# ── Codex CLI workspace ────────────────────────────────────────
if [ -t 1 ]; then
  echo ""
  printf '\033[1;36m  ╔══════════════════════════════════════════╗\n'
  printf '\033[1;36m  ║     \033[1;37mOpenAI Codex CLI Workspace\033[1;36m         ║\n'
  printf '\033[1;36m  ╠══════════════════════════════════════════╣\n'
  printf '\033[1;36m  ║  \033[0;37mRun:\033[0m  codex                           \033[1;36m║\n'
  printf '\033[1;36m  ║  \033[0;37mAuth:\033[0m export OPENAI_API_KEY=sk-...    \033[1;36m║\n'
  printf '\033[1;36m  ║  \033[0;37mGH:\033[0m   gh auth login                  \033[1;36m║\n'
  printf '\033[1;36m  ╚══════════════════════════════════════════╝\n'
  printf '\033[0m\n'
fi
BASHRC

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
