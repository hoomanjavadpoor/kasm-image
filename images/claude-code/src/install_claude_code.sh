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

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
