# 🧰 Docpier Engineering Bootstrap

This repo bootstraps and manages your full local development setup for **Docpier engineers** on **macOS** and **Linux**. It ensures a clean, consistent, and automated developer environment.

---

## ✅ What It Does

- Creates standard `~/Engineering` workspace  
- Installs required CLI tools using Homebrew  
- Manages language versions using [`asdf`](https://asdf-vm.com/)  
- Authenticates with GitHub via SSH and `gh` CLI  
- Clones all repos from the `Docpier-Labs` GitHub org  
- Sets up the custom `dp` CLI  

---

## 📁 Folder Structure

```
~/Engineering/
├── repos/               # All GitHub repos (auto-synced)
│   └── dev-bootstrap/   # This repository lives here
├── playgrounds/         # For experiments and temp work
```

---

## 🧱 Tooling Stack

| Tool      | Use Case                                      |
|-----------|-----------------------------------------------|
| **Homebrew** | Installs system packages & GUI apps         |
| **asdf**   | Manages language runtimes (Node, Java, Python) |
| **gh**     | GitHub CLI for repo sync and key mgmt        |
| **dp**     | Custom CLI helper for daily dev workflows     |

---

## 🚀 Bootstrap Setup

Run this one-liner to set up your machine:

```bash
bash <(curl -sL https://raw.githubusercontent.com/Docpier-Labs/dev-bootstrap/main/bootstrap.sh)
```

What it does:
- Installs Homebrew, Git, `gh`, `asdf`
- Generates SSH key and adds it to GitHub
- Clones `dev-bootstrap` repo into `~/Engineering/repos`
- Installs GUI apps from `Brewfile`
- Installs runtimes via `.tool-versions` with `asdf`
- Sets up and links the `dp` CLI globally
- Clones all GitHub repos from `Docpier-Labs`

---

## 🔁 Daily Usage

| Task                     | Command                      |
|--------------------------|------------------------------|
| Sync repos               | `dp sync`                    |
| Update bootstrap setup   | `git pull` inside `dev-bootstrap` |
| Open any repo            | `cd ~/Engineering/repos/<repo>` |
| Run commands             | Use the `dp` CLI (see below) |

---

## 🧪 dp CLI

A developer helper tool. Commands include:

```bash
dp sync                # Pull/update all org repos
dp ctx                 # Switch Kubernetes context
dp logs <svc>          # Tail logs from a K8s service
dp deploy dev          # Deploy app to local env
dp restart <svc>       # Restart K8s deployment
dp docker push <svc>   # Build + push Docker image
dp port-forward <svc>  # Port-forward from K8s to localhost
```

To add new commands:  
Create a file in `dp/src/commands/*.ts`.

---

## 🛠 Language Versions

We use [`asdf`](https://asdf-vm.com/) to ensure all devs use consistent versions.

### Sample `.tool-versions`:

```
java temurin-21.0.1+12
nodejs 22.2.0
python 3.11.9
```

To install and activate versions:

```bash
asdf install
asdf global nodejs 22.2.0
```

---

## 🧩 GUI Tools

Installed via Homebrew `Brewfile`:

- **Editors**: VS Code, IntelliJ, Cursor  
- **Docker Tools**: Docker Desktop, Testcontainers Desktop  
- **Kubernetes**: Lens  
- **Productivity**: Raycast, Notion, Linear  
- **Utilities**: DevToys, Boop, Go2Shell, Apidog  
- **Communication**: Slack, WhatsApp  
- **Browsers**: Chrome, Firefox  

---

## 🔐 GitHub SSH Setup

- SSH key is auto-generated if missing  
- Automatically uploaded to GitHub via `gh`  
- Git is configured to use SSH instead of HTTPS  

---

## 💡 Tips

- Re-run `bootstrap.sh` safely — it won't override your SSH key or Git config unless you say so  
- Use `asdf` to manage runtime versions  
- Put your playground work in `~/Engineering/playgrounds`  
- All cloned repos live in `~/Engineering/repos`  

---

## 🧵 References

- [asdf](https://github.com/asdf-vm/asdf)  
- [GitHub CLI](https://cli.github.com)  
- [Docpier Bootstrap Repo](https://github.com/Docpier-Labs/dev-bootstrap)  
- [direnv](https://direnv.net) (for auto-loading env per project)  
- [SSH GitHub Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
