#!/bin/bash

SWAP_SIZE="5G"
SWAP_FILE="/swapfile"

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (sudo bash $0)"
    exit 1
fi

# Remove existing swap file if present
if [ -f "$SWAP_FILE" ]; then
    echo "Existing swap file found. Removing..."
    swapoff "$SWAP_FILE" 2>/dev/null || true
    rm -f "$SWAP_FILE"
fi

# Check available disk space
AVAILABLE=$(df / --output=avail -B1G | tail -1 | tr -d ' ')
echo "Available disk space: ${AVAILABLE}GB"
if [ "$AVAILABLE" -lt 6 ]; then
    echo "Error: Less than 6GB of free disk space. Aborting."
    exit 1
fi

# Create swap file
echo "Creating ${SWAP_SIZE} swap file at ${SWAP_FILE}..."
fallocate -l "$SWAP_SIZE" "$SWAP_FILE" 2>/dev/null || dd if=/dev/zero of="$SWAP_FILE" bs=1G count=5 status=progress

# Set correct permissions
chmod 600 "$SWAP_FILE"

# Format as swap
mkswap "$SWAP_FILE"

# Enable swap
swapon "$SWAP_FILE"

# Make persistent across reboots
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "${SWAP_FILE} none swap sw 0 0" >> /etc/fstab
fi

# Set swappiness to 10
sysctl vm.swappiness=10
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
fi

echo ""
echo "============================================"
echo " Swap enabled successfully!"
echo "============================================"
echo ""
swapon --show
echo ""
free -h
