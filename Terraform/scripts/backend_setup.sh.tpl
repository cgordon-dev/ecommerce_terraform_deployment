#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#set variables
REPO_URL="https://github.com/cgordon-dev/ecommerce_terraform_deployment.git"
PROJECT_DIR="/home/ubuntu/ecommerce_terraform_deployment/backend"
SETTINGS_FILE="$PROJECT_DIR/my_project/settings.py"

#Adding public key to the backend instance authorized_keys file
echo "${public_key}" >> ~/.ssh/authorized_keys

#update apt for the backend instances
sudo apt update && sudo apt upgrade -y


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


#install python 3.9 & packages
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.9 python3.9-venv python3.9-dev git -y


# Clone the workload repository
echo "Cloning workload repository..."
git clone $REPO_URL || { echo "Failed to clone repository."; exit 1;}
echo "Attempting to enter backend directory..."
cd $PROJECT_DIR || { echo "Failed to enter directory!"; exit 1;}

# Create and activate a Python virtual environment
echo "Setting up Python virtual environment..."
python3.9 -m venv venv
source venv/bin/activate

# Install dependencies from requirements.txt
echo "Installing dependencies..."
pip install -r requirements.txt


# Modify settings.py to update ALLOWED_HOSTS
echo "Updating ALLOWED_HOSTS in settings.py..."
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = [\"$(hostname -I | awk '{print $1}')\"]/g" $SETTINGS_FILE

# Modify settings.py to update PASSWORD with db_password variable
echo "Updating PASSWORD in settings.py..."
sed -i "s/'PASSWORD': '.*'/'PASSWORD': '${db_password}'/" my_project/settings.py

# Modify settings.py to update HOST with RDS Endpoint variable
echo "Updating HOST in settings.py..."
sed -i "s/'HOST': '.*'/'HOST': '${rds_endpoint}'/" my_project/settings.py

#Create the tables in RDS and populate data:
echo "Creating database schema..." 
python manage.py makemigrations account
python manage.py makemigrations payments
python manage.py makemigrations product
python manage.py migrate

echo "Loading data into RDS database..."
#Migrate the data from SQLite file to RDS:
python manage.py dumpdata --database=sqlite --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > datadump.json

python manage.py loaddata datadump.json

echo "Data loading completed successfully!"


# Start the Django development server
echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000
