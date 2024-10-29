#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#set variables
REPO_URL="https://github.com/cgordon-dev/ecommerce_terraform_deployment.git"
PROJECT_DIR="/home/ubuntu/ecommerce_terraform_deployment/frontend"
BACKEND_PRIVATE_IP="${private_ip}"


# Update and install Node.js and npm
echo "Updating system and installing Node.js..."
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs git

echo "Installing Prometheus Node Exporter..."
# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y wget

# Download and install Prometheus Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.0.linux-amd64.tar.gz
sudo mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.0.linux-amd64*

# Create a systemd service for Prometheus Node Exporter to run as 'ubuntu'
cat <<EOL | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
User=ubuntu
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Start and enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Prometheus Node Exporter successfully installed!"



# Clone the workload repository
echo "Cloning workload repository..."
git clone $REPO_URL || { echo "Failed to clone repository."; exit 1;}
echo "Attempting to enter frontend directory..."
cd $PROJECT_DIR || { echo "Failed to enter directory!"; exit 1;}

# Update package.json to set the proxy to backend private IP
echo "Updating package.json to set the proxy..."
sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/$BACKEND_PRIVATE_IP:8000/" package.json

# Install React project dependencies
echo "Installing dependencies..."
npm i

# Set Node.js options for legacy compatibility
echo "Setting Node.js options for legacy compatibility..."
export NODE_OPTIONS=--openssl-legacy-provider

# Start the React app
echo "Starting app..."
npm start
