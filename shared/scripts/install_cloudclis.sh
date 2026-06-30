#!/usr/bin/env bash
# Shared: install az cli, aws cli, gcp cli, gh cli
set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release apt-transport-https unzip

# ── Azure CLI ──────────────────────────────────────────────────
mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
printf "Types: deb\nURIs: https://packages.microsoft.com/repos/azure-cli/\nSuites: %s\nComponents: main\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/microsoft.gpg\n" \
    "$AZ_DIST" "$(dpkg --print-architecture)" \
    > /etc/apt/sources.list.d/azure-cli.sources

apt-get update
apt-get install -y azure-cli

# ── AWS CLI v2 ─────────────────────────────────────────────────
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp/awscliv2
/tmp/awscliv2/aws/install
rm -rf /tmp/awscliv2.zip /tmp/awscliv2

# ── Google Cloud CLI ───────────────────────────────────────────
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list

apt-get update
apt-get install -y google-cloud-cli

# ── GitHub CLI ─────────────────────────────────────────────────
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list

apt-get update
apt-get install -y gh

# ── kubectl + bash autocompletion ─────────────────────────────
apt-get install -y bash-completion

KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# Generate completion script (runs against the freshly installed binary)
mkdir -p /etc/bash_completion.d
kubectl completion bash > /etc/bash_completion.d/kubectl

# Global bashrc: source completion + convenience alias
cat >> /etc/bash.bashrc <<'BASHRC'

# ── kubectl autocompletion ─────────────────────────────────────
if command -v kubectl &>/dev/null; then
    # shellcheck disable=SC1091
    source /etc/bash_completion.d/kubectl 2>/dev/null || true
    alias k=kubectl
    complete -o default -F __start_kubectl k
fi
BASHRC

# ── Cleanup ────────────────────────────────────────────────────
apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
chown -R 1000:0 "$HOME"
