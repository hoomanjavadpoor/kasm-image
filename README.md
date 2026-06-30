# kasm-image

Six custom [Kasm Workspaces](https://kasmweb.com/) single-app images, built daily and published to the GitHub Container Registry.

## Images

| Image | Tools | GHCR tag |
|-------|-------|----------|
| `lens-cloudcli` | Lens Desktop + kubectl + helm + az + aws + gcp + gh | `ghcr.io/<owner>/kasm-lens-cloudcli:rolling-daily` |
| `codex` | OpenAI Codex CLI + gh | `ghcr.io/<owner>/kasm-codex:rolling-daily` |
| `antigravity` | Python 3 + antigravity + gh | `ghcr.io/<owner>/kasm-antigravity:rolling-daily` |
| `claude-code` | Anthropic Claude Code CLI + gh | `ghcr.io/<owner>/kasm-claude-code:rolling-daily` |
| `warp-cloudcli` | Warp Terminal + az + aws + gcp + gh | `ghcr.io/<owner>/kasm-warp-cloudcli:rolling-daily` |
| `anydesk` | AnyDesk | `ghcr.io/<owner>/kasm-anydesk:rolling-daily` |

Replace `<owner>` with your GitHub username or organisation name.

## Repository layout

```
.
├── shared/scripts/
│   ├── install_cloudclis.sh   # az + aws + gcp + gh (reused by lens & warp images)
│   └── install_gh.sh          # gh only
├── images/
│   ├── lens-cloudcli/
│   │   ├── Dockerfile
│   │   └── src/
│   │       ├── install_lens.sh
│   │       └── custom_startup.sh
│   ├── codex/
│   ├── antigravity/
│   ├── claude-code/
│   ├── warp-cloudcli/
│   └── anydesk/
└── .github/workflows/
    └── build-images.yml       # daily matrix build → ghcr.io
```

Each Dockerfile uses `.` (repo root) as its build context so that shared scripts can be `COPY`-ed into any image.

## CI/CD

The workflow `.github/workflows/build-images.yml` runs:
- **On schedule** – every day at `02:00 UTC`
- **On `workflow_dispatch`** – manual trigger from the Actions tab

It builds all six images in parallel (matrix strategy), pulls the latest `kasmweb/core-ubuntu-jammy:1.19.0-rolling-daily` base on every run, and publishes two tags per image:
- `rolling-daily` – always points to the latest daily build
- `latest`

GitHub Actions layer caching (`cache-from/cache-to: type=gha`) is scoped per image, so unchanged layers are reused across daily builds.

### Required permissions

The workflow uses `GITHUB_TOKEN` (auto-provided by Actions) to push to GHCR. Ensure the repository **Packages** write permission is granted under _Settings → Actions → General → Workflow permissions_.

## Building locally

All Dockerfiles expect the **repo root** as the build context:

```bash
# Example: build the codex image
docker build -t kasm-codex:dev -f images/codex/Dockerfile .

# Example: build the lens image
docker build -t kasm-lens-cloudcli:dev -f images/lens-cloudcli/Dockerfile .
```

## Registering in Kasm Workspaces

After pushing an image, add it as a workspace in the Kasm admin UI:

1. **Workspaces → Add Workspace**
2. Set **Docker Image** to the full GHCR tag (e.g. `ghcr.io/<owner>/kasm-codex:rolling-daily`).
3. Set **Workspace Type** to `Container`.
4. If the registry is private, supply a Docker Registry Username/Password (use a GitHub PAT with `read:packages` scope).
5. Save and launch.

## Notes

### Warp Terminal (`warp-cloudcli`)
Warp Terminal requires GPU/hardware-accelerated rendering. In some Kasm deployments without GPU passthrough it may fall back to software rendering or fail to start. If you encounter display issues, set the `APP_ARGS` environment variable in the Kasm workspace to `--disable-gpu` as a workaround.

### API keys for Codex and Claude Code
Both images open an `xterm` terminal. The CLI tools require API keys at runtime — they are **not** baked into the image:

```bash
# Inside the session terminal
export OPENAI_API_KEY="sk-..."       # for codex
export ANTHROPIC_API_KEY="sk-ant-..." # for claude-code
```

Use Kasm [Workspace Launch Forms](https://docs.kasm.com/docs/1.19.0/how-to/workspaces-sessions/container-workspace/workspace-launch-form) or persistent profiles to inject credentials securely.
