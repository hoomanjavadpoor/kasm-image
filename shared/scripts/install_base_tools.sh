#!/usr/bin/env bash
# Install Go (latest stable) and Python 3 with pip/venv
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Python 3 ───────────────────────────────────────────────────
apt-get update
apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python-is-python3

# ── Go (latest stable) ─────────────────────────────────────────
GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)
curl -fsSL "https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz" \
    -o /tmp/go.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tar.gz

# Expose Go binaries to all login/interactive shells
cat > /etc/profile.d/go.sh <<'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
chmod 644 /etc/profile.d/go.sh

# Also pick up in non-login bash sessions (Kasm terminals)
cat >> /etc/bash.bashrc <<'EOF'

# Go toolchain
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
