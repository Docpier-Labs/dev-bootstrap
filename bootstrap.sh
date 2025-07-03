#!/bin/bash

set -e

echo "Creating Engineering folders..."
mkdir -p ~/Engineering/{repos,playgrounds}

# --- Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Force GitHub to use SSH instead of HTTPS ---
echo "Configuring Git to use SSH for GitHub..."
git config --global url."git@github.com:".insteadOf "https://github.com/"

# --- Install Git if missing ---
if ! command -v git >/dev/null 2>&1; then
  echo "Installing Git..."
  brew install git
fi

# --- Git identity setup ---
existing_email=$(git config --global user.email || true)

if [[ "$existing_email" == *"@docpier.com" ]]; then
  echo "Git identity already set to $existing_email"
else
  read -p "Enter your GitHub username: " github_user
  read -p "Enter your GitHub email: " github_email

  git config --global user.name "$github_user"
  git config --global user.email "$github_email"
fi

# --- SSH Key Setup (only if missing) ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  echo "Creating new SSH key..."
  ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"

  echo "Uploading public key to GitHub..."
  gh ssh-key add "${SSH_KEY}.pub" --title "$(hostname)-bootstrap"
else
  echo "SSH key already exists: $SSH_KEY"
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
fi

# --- Clone dev-bootstrap from organization ---
cd ~/Engineering/repos

if [ -d dev-bootstrap ]; then
  echo "⚠Folder 'dev-bootstrap' already exists."
  read -p "Do you want to delete and re-clone it? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Removing existing 'dev-bootstrap'..."
    rm -rf dev-bootstrap
  else
    echo "Aborting bootstrap to avoid overwrite."
    exit 1
  fi
fi

echo "Cloning dev-bootstrap from Docpier-Labs..."
git clone git@github.com:Docpier-Labs/dev-bootstrap.git

cd dev-bootstrap

if [ -f Brewfile ]; then
  echo "Installing GUI apps from Brewfile..."
  brew bundle --file=Brewfile
else
  echo "Brewfile not found, skipping GUI apps installation."
fi

# ─── Ensure GitHub CLI Auth Exists ────────────────────────────────────────
if ! gh auth status &>/dev/null; then
  echo "GitHub CLI not authenticated. Running 'gh auth login'..."
  gh auth login
fi

# ─── Sync All Repos via gh ───────────────────────────────────────────────
echo "Syncing all repos from Docpier-Labs (SSH)..."

gh repo list Docpier-Labs --limit 1000 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv' |
while IFS=$'\t' read -r name sshUrl; do
  if [ -d "$HOME/Engineering/repos/$name" ]; then
    echo "$name exists. Pulling latest changes..."
    git -C "$HOME/Engineering/repos/$name" pull
  else
    echo "Cloning $name..."
    git clone "$sshUrl" "$HOME/Engineering/repos/$name"
  fi
done

# --- Devbox install ---
if ! command -v devbox >/dev/null 2>&1; then
  echo "Installing Devbox via official script..."
  curl -fsSL https://get.jetpack.io/devbox | bash

  export PATH="$HOME/.devbox/bin:$PATH"

  if [[ $SHELL == *"zsh" ]]; then
    echo 'export PATH="$HOME/.devbox/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
  elif [[ $SHELL == *"bash" ]]; then
    echo 'export PATH="$HOME/.devbox/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  fi
fi

# --- Ensure devbox.json exists ---
if [ ! -f devbox.json ]; then
  echo "devbox.json not found in dev-bootstrap. Aborting."
  exit 1
fi

echo "Launching Devbox shell..."
devbox shell
