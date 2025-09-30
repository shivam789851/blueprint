#!/bin/bash

# =======================================
#   SHIVAM Blueprints (RG) - Auto Install
#   Powered by SHIVAM
# =======================================

set -e
trap 'echo "❌ Error occurred at line $LINENO. Exiting..."; exit 1' ERR

# --- Logo Banner ---
logo_banner() {
cat << "EOF"
   _____   _    _   _____  __      __             __  __ 
  / ____| | |  | | |_   _| \ \    / /     /\     |  \/  |
 | (___   | |__| |   | |    \ \  / /     /  \    | \  / |
  \___ \  |  __  |   | |     \ \/ /     / /\ \   | |\/| |
  ____) | | |  | |  _| |_     \  /     / ____ \  | |  | |
 |_____/  |_|  |_| |_____|     \/     /_/    \_\ |_|  |_|
                                                         
                                                         
==================================
EOF
}

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run this script as root (use sudo)."
    exit 1
fi

clear
logo_banner
echo ">>> 🚀 Starting SHIVAM Blueprints (RG) Setup..."

# Step 1: Install Node.js 20.x
echo ">>> Installing Node.js 20.x..."
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
  tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs

# Step 2: Install Yarn & dependencies
echo ">>> Installing dependencies..."
npm i -g yarn
apt install -y zip unzip git curl wget

# Step 3: Setup in Pterodactyl directory
PTERO_DIR="/var/www/pterodactyl"
cd "$PTERO_DIR" || { echo "❌ Pterodactyl directory not found at $PTERO_DIR!"; exit 1; }
yarn

# Step 4: Download SHIVAM Hosting release
echo ">>> Downloading latest SHIVAM Hosting release..."
RELEASE_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
  | grep "browser_download_url.*zip" | cut -d '"' -f 4)
wget "$RELEASE_URL" -O release.zip

echo ">>> Extracting release files..."
unzip -o release.zip

# Step 5: Run blueprint.sh
if [ ! -f "blueprint.sh" ]; then
    echo "❌ Error: blueprint.sh not found in release package."
    exit 1
fi

chmod +x blueprint.sh
echo ">>> Running blueprint.sh for SHIVAM Blueprints..."
bash blueprint.sh

echo "✅ SHIVAM Blueprints (RG) setup completed successfully!"
