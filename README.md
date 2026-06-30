# kasm-image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Seven ready-to-use [Kasm Workspaces](https://kasmweb.com/) single-app images, rebuilt daily and published to the GitHub Container Registry. Add them to any Kasm deployment in seconds via the built-in registry.

## Available workspaces

| Workspace | What's inside |
|-----------|---------------|
| **Lens + Cloud CLIs** | Lens Desktop Kubernetes IDE · kubectl · Helm · Azure CLI · AWS CLI · Google Cloud CLI · GitHub CLI |
| **FreeLens + Cloud CLIs** | FreeLens (open-source K8s IDE) · kubectl · Helm · Azure CLI · AWS CLI · Google Cloud CLI · GitHub CLI |
| **OpenAI Codex CLI** | Codex CLI in xterm · GitHub CLI |
| **Google Antigravity** | Google Antigravity Hub desktop app |
| **Claude Desktop** | Anthropic Claude Desktop GUI app |
| **Warp + Cloud CLIs** | Warp Terminal · Azure CLI · AWS CLI · Google Cloud CLI · GitHub CLI · kubectl |
| **AnyDesk** | AnyDesk remote desktop client |

> Every image ships with **Go** (latest stable) and **Python 3** with pip/venv.

All images are tagged `rolling-daily` and rebuilt every night at 02:00 UTC from `kasmweb/core-ubuntu-jammy:1.19.0-rolling-daily`.

---

## Option 1 — Kasm Registry (recommended)

Add the entire collection to Kasm in one step.

1. In the Kasm admin UI go to **Admin → Registries → Add Registry**.
2. Set the registry URL to:
   ```
   https://hoomanjavadpoor.github.io/kasm-image/1.1/
   ```
3. Click **Save**. All seven workspaces will appear under **Workspaces → Add Workspace → From Registry**.


---

## Option 2 — Add a single image manually

1. Go to **Admin → Workspaces → Add Workspace**.
2. Set **Workspace Type** to `Container`.
3. Paste the GHCR image tag:

   | Workspace | Docker image |
   |-----------|-------------|
   | Lens + Cloud CLIs | `ghcr.io/hoomanjavadpoor/kasm-lens-cloudcli:rolling-daily` |
   | FreeLens + Cloud CLIs | `ghcr.io/hoomanjavadpoor/kasm-freelens-cloudcli:rolling-daily` |
   | OpenAI Codex CLI | `ghcr.io/hoomanjavadpoor/kasm-codex:rolling-daily` |
   | Google Antigravity | `ghcr.io/hoomanjavadpoor/kasm-antigravity:rolling-daily` |
   | Claude Desktop | `ghcr.io/hoomanjavadpoor/kasm-claude-code:rolling-daily` |
   | Warp + Cloud CLIs | `ghcr.io/hoomanjavadpoor/kasm-warp-cloudcli:rolling-daily` |
   | AnyDesk | `ghcr.io/hoomanjavadpoor/kasm-anydesk:rolling-daily` |

4. Leave all other settings at their defaults and click **Save**.

---

## Notes

### Codex — API key
The Codex workspace opens an xterm terminal. Set your OpenAI API key inside the session before running `codex`:
```bash
export OPENAI_API_KEY="sk-..."
```
Use Kasm [Workspace Environment Variables](https://www.kasmweb.com/docs/latest/how_to/persistent_data.html) or a launch form to inject it automatically.

### Warp Terminal — GPU rendering
Warp uses GPU-accelerated rendering. If the session fails to start or shows a blank window, add `--disable-gpu` to the **Docker Run Config Override → Environment** in the workspace settings:
```
APP_ARGS=--disable-gpu
```

### GHCR visibility
All images are published as **public** packages on GHCR. No authentication is needed to pull them.


---

## License

The Dockerfiles, scripts, and configuration files in this repository are released under the [MIT License](LICENSE) — you are free to use, copy, modify, merge, publish, distribute, sublicense, or sell them.

## Disclaimer

This repository **automates the download and installation of third-party software** inside container images. It does not redistribute, repackage, or claim ownership of any of those applications. Each application is subject to its own license and terms of service:

| Application | License / Terms |
|-------------|----------------|
| Lens Desktop | [MIT](https://github.com/lensapp/lens/blob/master/LICENSE) |
| FreeLens | [MIT](https://github.com/freelensapp/freelens/blob/main/LICENSE) |
| Warp Terminal | [Terms of Service](https://www.warp.dev/terms-of-service) |
| AnyDesk | [Terms](https://anydesk.com/en/terms) |
| OpenAI Codex CLI | [Terms of Use](https://openai.com/policies/terms-of-use) |
| Claude Code CLI | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| Google Antigravity | Google applicable terms of service |
| Helm | [Apache 2.0](https://github.com/helm/helm/blob/main/LICENSE) |
| kubectl | [Apache 2.0](https://github.com/kubernetes/kubectl/blob/master/LICENSE) |
| Azure CLI | [MIT](https://aka.ms/azure-cli-license) |
| AWS CLI v2 | [Apache 2.0](https://github.com/aws/aws-cli/blob/develop/LICENSE.txt) |
| Google Cloud CLI | [Terms](https://cloud.google.com/terms) |
| GitHub CLI | [MIT](https://github.com/cli/cli/blob/trunk/LICENSE) |

**By pulling or running these images you agree to the terms of each included application.**

All product names, logos, and trademarks are the property of their respective owners. This project is not affiliated with, endorsed by, or sponsored by any of the vendors listed above.
