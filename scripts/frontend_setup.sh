#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#set variables
REPO_URL="https://github.com/cgordon-dev/ecommerce_terraform_deployment.git"
PROJECT_DIR="/home/ubuntu/ecommerce_terraform_deployment/frontend"
BACKEND_PRIVATE_IP="<backend_private_ip>"


# Update and install Node.js and npm
echo "Updating system and installing Node.js..."
sudo apt update && sudo apt upgrade
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs git

# Clone the React project repository
echo "Cloning React repository..."
git clone $REPO_URL
cd $PROJECT_DIR

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
echo "Starting React app..."
npm start
