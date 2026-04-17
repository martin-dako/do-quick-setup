#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <yourdomain.com> <youremail@example.com> <your_keystore_password>"
    exit 1
fi

DOMAIN="$1"
EMAIL="$2"
PASSWORD="$3"

REPO_URL="https://github.com/martin-dako/do-database-quick-setup.git"
WORK_DIR="/var/https-setup"

# Install git if not present
if ! command -v git &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y git
fi

# Clean previous working dir for idempotency
if [ -d "$WORK_DIR" ]; then
    sudo rm -rf "$WORK_DIR"
fi

sudo mkdir -p "$WORK_DIR"
sudo chown "$USER":"$USER" "$WORK_DIR"
cd "$WORK_DIR"

# Sparse clone to fetch only scripts/https.sh
git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" .
git sparse-checkout set scripts/https.sh

# Make it executable and run with provided arguments
chmod +x scripts/https.sh
./scripts/https.sh "$DOMAIN" "$EMAIL" "$PASSWORD"
