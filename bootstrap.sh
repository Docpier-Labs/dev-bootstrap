#!/bin/bash
set -euo pipefail

echo "🚀 Creating Engineering folders..."
mkdir -p ~/Engineering/{repos,playgrounds}

# --- Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
  echo "🧰 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Install Git if missing ---
if ! command -v git >/dev/null 2>&1; then
  echo "🔧 Installing Git..."
  brew install git
fi

# --- Install GitHub CLI if missing ---
if ! command -v gh >/dev/null 2>&1; then
  echo "🔧 Installing GitHub CLI..."
  brew install gh
fi

# --- Configure Git to use SSH ---
echo "🔐 Configuring Git to use SSH for GitHub..."
git config --global url."git@github.com:".insteadOf "https://github.com/"

# --- Git identity setup ---
existing_email=$(git config --global user.email || true)
if [[ "$existing_email" == *"@docpier.com" ]]; then
  echo "✅ Git identity already set to $existing_email"
else
  read -p "👤 Enter your GitHub username: " github_user
  read -p "📧 Enter your GitHub email: " github_email
  git config --global user.name "$github_user"
  git config --global user.email "$github_email"
fi

# --- GitHub CLI Auth ---
if ! gh auth status &>/dev/null; then
  echo "🔐 GitHub CLI not authenticated. Running 'gh auth login'..."
  gh auth login
fi

# --- SSH Key Setup ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  echo "🔑 Creating new SSH key..."
  ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
else
  echo "✅ SSH key already exists."
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
fi

# Check if public key is uploaded
PUBKEY_CONTENT=$(cat "${SSH_KEY}.pub")
if gh ssh-key list | grep -q "$PUBKEY_CONTENT"; then
  echo "✅ SSH key already registered in GitHub."
else
  echo "🔗 Uploading SSH key to GitHub..."
  gh ssh-key add "${SSH_KEY}.pub" --title "$(hostname)-bootstrap"
fi

# --- Clone dev-bootstrap ---
cd ~/Engineering/repos
if [ -d dev-bootstrap ]; then
  echo "⚠ Folder 'dev-bootstrap' already exists."
  read -p "❓ Do you want to delete and re-clone it? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🗑 Removing existing 'dev-bootstrap'..."
    rm -rf dev-bootstrap
  else
    echo "⛔ Aborting bootstrap to avoid overwrite."
    exit 1
  fi
fi

echo "📦 Cloning dev-bootstrap from Docpier-Labs..."
git clone git@github.com:Docpier-Labs/dev-bootstrap.git
cd dev-bootstrap

# --- Install GUI apps if Brewfile exists ---
if [ -f Brewfile ]; then
  echo "🛠 Installing GUI apps from Brewfile..."
  brew bundle --file=Brewfile
else
  echo "⚠ Brewfile not found. Skipping GUI app installation."
fi

# --- Install Devbox ---
if ! command -v devbox >/dev/null 2>&1; then
  echo "📦 Installing Devbox..."
  curl -fsSL https://get.jetpack.io/devbox | bash
  export PATH="$HOME/.devbox/bin:$PATH"

  SHELL_RC=""
  [[ $SHELL == *"zsh" ]] && SHELL_RC="$HOME/.zshrc"
  [[ $SHELL == *"bash" ]] && SHELL_RC="$HOME/.bashrc"

  if [ -n "$SHELL_RC" ]; then
    echo 'export PATH="$HOME/.devbox/bin:$PATH"' >> "$SHELL_RC"
    echo "✅ Added Devbox to PATH in $SHELL_RC"
    echo "ℹ️ Please restart your terminal or run: source $SHELL_RC"
  fi
fi

# --- Ensure devbox.json exists ---
if [ ! -f devbox.json ]; then
  echo "❌ devbox.json not found. Aborting."
  exit 1
fi

# --- Sync All Repos from Docpier-Labs via GitHub CLI ---
echo "🔄 Syncing all repos from Docpier-Labs..."
gh repo list Docpier-Labs --limit 1000 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv' |
while IFS=$'\t' read -r name sshUrl; do
  target="$HOME/Engineering/repos/$name"
  if [ -d "$target" ]; then
    echo "📥 Pulling $name..."
    git -C "$target" pull --ff-only
  else
    echo "📦 Cloning $name..."
    git clone "$sshUrl" "$target"
  fi
done

# --- Run devbox update and shell ---
echo "🔧 Running devbox update..."
devbox update

if [[ -t 1 ]]; then
  echo "🧪 Entering Devbox shell..."
  devbox shell
else
  echo "✅ Devbox environment ready. Run 'devbox shell' to start."
fi
