#!/bin/bash

# Input param validation
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 yourdomain.com"
    exit 1
fi

DOMAIN=$1

# Install Certbot Apache plugin
echo "[+] Installing Certbot Apache plugin..."
apt update && apt install -y python3-certbot-apache

# Issue a new certificate with Apache pluginecho "[+] Issuing new certificate for $DOMAIN using Apache plugin..."
certbot --apache -d "$DOMAIN"

if [ $? -ne 0 ]; then
    echo "[-] Certificate issuance failed. Please check your Apache configuration."
    exit 1
fi

# Set Apache plugin permanently
echo "[+] Configuring Apache plugin permanently for domain $DOMAIN"
CONFIG_FILE="/etc/letsencrypt/renewal/${DOMAIN}.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[-] Configuration file $CONFIG_FILE does not exist."
    exit 1
fi

sed -i '/^authenticator\s*=\s*/d' "$CONFIG_FILE"
sed -i '/^installer\s*=\s*/d' "$CONFIG_FILE"

cat <<EOF >> "$CONFIG_FILE"
authenticator = apache
installer = apache
EOF

# Final dry-run to confirm configuration
echo "[+] Confirming final configuration (dry-run renewal)..."
certbot renew --dry-run

if [ $? -eq 0 ]; then
    echo "[+] Certbot Apache plugin setup completed successfully."
    echo "[+] Certificate is issued correctly."
else
    echo "[-] There was an issue with the final dry-run. Please check manually."
fi
