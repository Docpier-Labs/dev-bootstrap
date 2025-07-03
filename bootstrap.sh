#!/bin/bash

set -e

echo "📁 Creating Engineering folders..."
mkdir -p ~/Engineering/{repos,playgrounds}

# --- Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Force GitHub to use SSH instead of HTTPS ---
echo "🔧 Configuring Git to use SSH for GitHub..."
git config --global url."git@github.com:".insteadOf "https://github.com/"

# --- Install Git if missing ---
if ! command -v git >/dev/null 2>&1; then
  echo "🐙 Installing Git..."
  brew install git
fi

# --- Git identity setup ---
read -p "👤 Enter your GitHub username: " github_user
read -p "📧 Enter your GitHub email: " github_email

git config --global user.name "$github_user"
git config --global user.email "$github_email"

# --- SSH Key setup ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  echo "🔐 Creating new SSH key..."
  ssh-keygen -t ed25519 -C "$github_email" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"

  echo "📝 Copy this public key to your GitHub SSH settings:"
  echo "----------------------------------------------------"
  cat "${SSH_KEY}.pub"
  echo "----------------------------------------------------"
  echo "🔗 https://github.com/settings/keys"
  read -p "📎 Press Enter after adding your key to GitHub..."
else
  echo "✅ SSH key already exists: $SSH_KEY"
fi

# --- Clone dev-bootstrap from organization ---
cd ~/Engineering/repos
if [ ! -d dev-bootstrap ]; then
  echo "📦 Cloning dev-bootstrap from Docpier-Labs..."
  git clone git@github.com:Docpier-Labs/dev-bootstrap.git
fi

cd dev-bootstrap

# --- Devbox install ---
if ! command -v devbox >/dev/null 2>&1; then
  echo "📦 Installing Devbox..."
  brew install jetpack-io/devbox/devbox
fi

echo "🧪 Launching Devbox shell..."
devbox shell
