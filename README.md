
# 🛠️ Docpier Engineering Dev Bootstrap

This repository bootstraps and maintains the local development environment for **Docpier engineers** on macOS and Linux. It ensures:

- A unified workspace under `~/Engineering`
- Dev tools managed via [Devbox](https://www.jetpack.io/devbox/)
- SSH-authenticated GitHub access
- All GitHub organization repos are cloned via `ghorg`
- A custom `dp` CLI to simplify daily developer tasks

---

## 📁 Folder Structure

```
~/Engineering/
├── repos/               # All GitHub repos (auto-synced from Docpier-Labs org)
│   └── dev-bootstrap/   # This repo is cloned here
├── playgrounds/         # Experiments and temporary work
```

---

## 🔧 Tooling Overview

| Tool        | Purpose                                           |
|-------------|---------------------------------------------------|
| **Devbox**  | Reproducible dev environment (install tools/packages)
| **ghorg**   | Clone/pull all private GitHub repos under the org
| **dp**      | Custom CLI with shortcuts for daily workflows
| **Devcontainer** | (Optional) VSCode support for remote/local setup

---

## 🧪 Devbox

**Devbox** installs and manages dev tools like:

- `docker`, `node`, `python`, `jq`, `k6`, `kubectl`, `helm`, `zsh`, etc.
- Works similarly to `nix`, but easier for onboarding

To start using it:
```bash
cd ~/Engineering/repos/dev-bootstrap
devbox shell
```

### Automatically loaded tools:
- Shell autocomplete, syntax highlighting (via zsh plugins)
- `nvm` for Node, `pyenv` for Python, `sdkman` for Java
- All CLI tools defined in `devbox.json`

---

## 🚀 Bootstrap From Scratch

To set up your full environment:
```bash
bash <(curl -sL https://raw.githubusercontent.com/Docpier-Labs/dev-bootstrap/main/bootstrap.sh)
```

This script will:
- Install Git & Devbox
- Generate SSH key if needed
- Clone `dev-bootstrap` repo
- Set up SSH-based GitHub access
- Sync all repos from `Docpier-Labs` via `ghorg`
- Launch `devbox shell`

---

## 🔄 Daily Updates

```bash
devbox task update     # Pull updates from bootstrap repo
dp sync                # Pull latest repos via ghorg
```

---

## 🧠 dp CLI

```bash
dp sync             # Sync repos via ghorg
dp ctx              # Switch kube context
dp deploy dev       # Deploy to local env
dp logs service     # Tail logs from service
dp restart service  # Restart a K8s deployment
dp port-forward svc # Port-forward from local
dp docker push svc  # Build and push Docker image to ACR
```

---

## 🧪 Local Kubernetes

We support running **your full stack locally** with:
- `kind` cluster (Kubernetes in Docker)
- `kustomize` manifests
- ACR images loaded directly into kind

```bash
devbox task setup-local-k8s
```

---

## 🔐 GitHub SSH Setup

- SSH key created if none exists
- You’ll be prompted to upload your key manually to GitHub
- Ensures `ghorg` and `git` access works securely

---

## ❓ FAQ

### Do I need to run `devbox shell` every time?

Yes, unless you use [`direnv`](https://direnv.net/) to auto-load it. Recommended.

### What if I want a new CLI command?

Add a new script in `dp/src/commands/*.ts` — it will be auto-loaded.

### Where can I find my repos?

All synced under `~/Engineering/repos`.

---

## 📎 Reference

- Devbox: https://www.jetpack.io/devbox
- ghorg: https://github.com/gabrie30/ghorg
- direnv: https://direnv.net
- SSH GitHub setup: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
