#!/bin/bash
# FOR TOMCAT AND SPRINGBOOT:
# server.ssl.key-store=/etc/letsencrypt/live/yourdomain.com/keystore.jks
# server.ssl.key-store-password=your_keystore_password
# server.ssl.key-store-type=JKS


# Check if the required arguments are provided
if [ $# -ne 3 ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <yourdomain.com> <youremail@example.com> <your_keystore_password>"
    exit 1
fi

# Assign command-line arguments to variables
DOMAIN="$1"
EMAIL="$2"
PASSWORD="$3"

# Update system packages
sudo apt-get update

# Install Certbot
sudo apt-get install -y certbot

# Install OpenSSL if not already installed
sudo apt-get install -y openssl

# Stop any services that might be using port 80
sudo systemctl stop apache2
sudo systemctl stop nginx

# Obtain SSL certificate using Certbot in standalone mode
sudo certbot certonly --standalone -d "$DOMAIN" --non-interactive --agree-tos --email "$EMAIL"

# Generate PKCS12 keystore from the obtained certificate
sudo openssl pkcs12 -export \
    -in /etc/letsencrypt/live/"$DOMAIN"/fullchain.pem \
    -inkey /etc/letsencrypt/live/"$DOMAIN"/privkey.pem \
    -out /etc/letsencrypt/live/"$DOMAIN"/keystore.p12 \
    -name tomcat \
    -CAfile /etc/letsencrypt/live/"$DOMAIN"/chain.pem \
    -caname root \
    -password pass:"$PASSWORD"

# Import the PKCS12 keystore into a Java keystore
sudo keytool -importkeystore \
    -deststorepass "$PASSWORD" \
    -destkeypass "$PASSWORD" \
    -destkeystore /etc/letsencrypt/live/"$DOMAIN"/keystore.jks \
    -srckeystore /etc/letsencrypt/live/"$DOMAIN"/keystore.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass "$PASSWORD" \
    -alias tomcat -noprompt

# Change ownership of the keystore to the current user
sudo chown "$USER":"$USER" /etc/letsencrypt/live/"$DOMAIN"/keystore.jks

# Create a renewal hook script to update the keystore upon certificate renewal
sudo bash -c "cat > /etc/letsencrypt/renewal-hooks/deploy/00-renewal.sh <<EOF
#!/bin/bash

PASSWORD=\"$PASSWORD\"
DOMAIN=\"$DOMAIN\"

openssl pkcs12 -export \\
    -in /etc/letsencrypt/live/\"\$DOMAIN\"/fullchain.pem \\
    -inkey /etc/letsencrypt/live/\"\$DOMAIN\"/privkey.pem \\
    -out /etc/letsencrypt/live/\"\$DOMAIN\"/keystore.p12 \\
    -name tomcat \\
    -CAfile /etc/letsencrypt/live/\"\$DOMAIN\"/chain.pem \\
    -caname root \\
    -password pass:\"\$PASSWORD\"

keytool -importkeystore \\
    -deststorepass \"\$PASSWORD\" \\
    -destkeypass \"\$PASSWORD\" \\
    -destkeystore /etc/letsencrypt/live/\"\$DOMAIN\"/keystore.jks \\
    -srckeystore /etc/letsencrypt/live/\"\$DOMAIN\"/keystore.p12 \\
    -srcstoretype PKCS12 \\
    -srcstorepass \"\$PASSWORD\" \\
    -alias tomcat -noprompt
EOF"

# Make the renewal hook executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/00-renewal.sh

echo "SSL setup is complete. Please configure your Java application to use the keystore at /etc/letsencrypt/live/$DOMAIN/keystore.jks with the password you provided."

echo "FOR TOMCAT:"
echo "server.ssl.key-store=/etc/letsencrypt/live/$DOMAIN/keystore.jks"
echo "server.ssl.key-store-password=$PASSWORD"
echo "server.ssl.key-store-type=JKS"