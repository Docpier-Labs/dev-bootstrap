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

# --- Install GUI + CLI apps via Brewfile ---
if [ -f Brewfile ]; then
  echo "🛠 Installing all apps from Brewfile..."
  brew bundle --file=Brewfile
else
  echo "⚠ Brewfile not found. Skipping installation."
fi

# --- Sync all repos from GitHub org via gh CLI ---
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

# --- Setup dp CLI ---
if [ -f ./dp/index.ts ]; then
  echo "🛠 Setting up dp CLI..."

  if ! command -v tsx >/dev/null 2>&1; then
    echo "Installing tsx for TypeScript CLI execution..."
    npm install -g tsx
  fi

  echo '#!/bin/bash' > dp.sh
  echo 'exec tsx '"$(pwd)/dp/index.ts"' "$@"' >> dp.sh
  chmod +x dp.sh
  sudo mv dp.sh /usr/local/bin/dp

  echo "✅ dp CLI is now globally available."
else
  echo "⚠️ Could not find dp/index.ts. Skipping dp CLI setup."
fi

echo "✅ Bootstrap complete. You're ready to develop."
