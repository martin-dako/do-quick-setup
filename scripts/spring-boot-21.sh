#!/bin/bash

# Check if the necessary variables are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <REPO_URL> <TOKEN> <PORT>"
  exit 1
fi

# External variables
REPO_URL="$1"
TOKEN="$2"
PORT="$3"

# Remove existing install.sh if it exists
if [ -f /var/install.sh ]; then
  sudo rm /var/install.sh
fi

# Define the script's content with embedded variables
SCRIPT_CONTENT=$(cat <<EOF
#!/bin/bash

# Embedded variables
REPO_URL="$REPO_URL"
TOKEN="$TOKEN"
PORT="$PORT"

# Extract the repository name from the URL
REPO_NAME=\$(basename -s .git "\$REPO_URL")
REPO_DIR="/var/repos/\$REPO_NAME"
LOG_DIR="/var/repo-logs"
TIMESTAMP=\$(date +"%Y-%m-%d_%H-%M-%S.%3N")
LOG_FILE="\$LOG_DIR/\${REPO_NAME}_\${TIMESTAMP}.txt"

# Ensure log directory exists
sudo mkdir -p "\$LOG_DIR"

# Install necessary packages if not already installed
sudo apt-get update

# Install Git
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
fi

# Install Node.js and npm
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    sudo apt-get install -y nodejs npm
fi

# Install Java 21 (OpenJDK)
if ! java -version 2>&1 | grep -q "21"; then
    sudo apt-get install -y openjdk-21-jdk
fi

# Install PM2 globally using npm
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
fi

# Clone or update the repository
if [ -d "\$REPO_DIR" ]; then
    echo "Repository exists. Checking for changes..."
    cd "\$REPO_DIR"
    
    # Fetch latest changes
    git fetch

    # Check if there are any changes
    LOCAL_COMMIT=\$(git rev-parse HEAD)
    REMOTE_COMMIT=\$(git rev-parse @{u})

    if [ "\$LOCAL_COMMIT" = "\$REMOTE_COMMIT" ]; then
        echo "Repository is unchanged. The script will not continue."
        exit 0
    else
        echo "Repository has changes. Pulling the latest changes..."
        git pull
    fi
else
    echo "Cloning the repository..."
    sudo mkdir -p "\$REPO_DIR"
    sudo git clone https://\$TOKEN@\${REPO_URL#https://} "\$REPO_DIR"
    cd "\$REPO_DIR"
fi

# Make the Gradle wrapper executable
if [ -f "./gradlew" ]; then
    chmod +x gradlew
    # Run the Gradle assemble task and save output to log file
    ./gradlew assemble &> "\$LOG_FILE"
else
    echo "Gradle wrapper not found. Please ensure your project has a gradlew file."
    exit 1
fi

# Find the correct JAR file, excluding any "-plain.jar" files
JAR_FILE=\$(find build/libs -type f -name "*.jar" ! -name "*-plain.jar" | head -n 1)

if [ -z "\$JAR_FILE" ]; then
    echo "No valid JAR file found in build/libs. Please check your Gradle build configuration."
    exit 1
fi

# Stop and remove any existing PM2 process with the same name
pm2 delete "\$REPO_NAME" 2> /dev/null || true

# Start the new application with PM2 and specified port
pm2 start "java -jar \$REPO_DIR/\$JAR_FILE --server.port=\$PORT" --name "\$REPO_NAME"

# Save the PM2 process list and set up startup script
pm2 save
pm2 startup | tail -n 1 | bash

echo "Deployment complete. The application is running with PM2 on port \$PORT."
EOF
)

# Save the script to /var/install.sh
echo "$SCRIPT_CONTENT" | sudo tee /var/install.sh > /dev/null

# Make the script executable
sudo chmod +x /var/install.sh

# Notify the user
echo "The script has been created at /var/install.sh and can be run by executing ./install.sh"
sudo /var/install.sh