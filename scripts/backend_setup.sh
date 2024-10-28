#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#set variables
REPO_URL="https://github.com/cgordon-dev/ecommerce_terraform_deployment.git"
PROJECT_DIR="/home/ubuntu/ecommerce_terraform_deployment/backend"
BACKEND_PRIVATE_IP="<backend_private_ip>"


#update apt for the backend instances
sudo apt update && sudo apt upgrade

#install python 3.9 & packages
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.9 python3.9-venv python3.9-dev -y


# Clone the Django project repository
echo "Cloning Django repository..."
git clone $REPO_URL 
cd $PROJECT_DIR

# Create and activate a Python virtual environment
echo "Setting up Python virtual environment..."
python3.9 -m venv venv
source venv/bin/activate

# Install dependencies from requirements.txt
echo "Installing dependencies..."
pip install -r requirements.txt


# Modify settings.py to update ALLOWED_HOSTS
echo "Updating ALLOWED_HOSTS in settings.py..."
SETTINGS_FILE="$PROJECT_DIR/my_project/settings.py"
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$BACKEND_PRIVATE_IP', 'localhost']/" $SETTINGS_FILE


# Start the Django development server
echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000
