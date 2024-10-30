#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#set variables
REPO_URL="https://github.com/cgordon-dev/ecommerce_terraform_deployment.git"
PROJECT_DIR="/home/ubuntu/ecommerce_terraform_deployment/backend"
SETTINGS_FILE="$PROJECT_DIR/my_project/settings.py"

#Adding public key to the backend instance authorized_keys file
SSH_PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="

echo "$SSH_PUB_KEY" >> /home/ubuntu/.ssh/authorized_keys


####### SECTION FOR PROMETHEUS NODE EXPORTER ########


# Install wget if not already installed
sudo apt install wget -y


# Download and install Node Exporter
NODE_EXPORTER_VERSION="1.5.0"
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar xvfz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*

# Create a Node Exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create a Node Exporter service file
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, start and enable Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Print the public IP address and Node Exporter port
echo "Node Exporter installation complete. It's accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"



###### SECTION FOR DJANGO APP ###########
#update apt for the backend instances
sudo apt update && sudo apt upgrade

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


# Configuring RDS DB information in settings.py
echo "Updating ALLOWED_HOSTS in settings.py..."
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = [\"$(hostname -I | awk '{print $1}')\"]/g" $SETTINGS_FILE

echo "Updating ENGINE in settings.py..."
sed -i "s/#'ENGINE': 'django.db.backends.postgresql'/'ENGINE': 'django.db.backends.postgresql'/g" $SETTINGS_FILE || { echo "Unable to uncomment ENGINE field."; exit 1; }

echo "Updating NAME in settings.py..."
sed -i "s/#'NAME': 'your_db_name'/'NAME': '${db_name}'/g" $SETTINGS_FILE || { echo "DB Name failed to update."; exit 1; }

echo "Updating USER in settings.py..."
sed -i "s/#'USER': 'your_username'/'USER': '${db_username}'/g" $SETTINGS_FILE || { echo "DB Username failed to update."; exit 1; }

echo "Updating PASSWORD in settings.py..."
sed -i "s/#'PASSWORD': 'your_password'/'PASSWORD': '${db_password}'/g" $SETTINGS_FILE || { echo "DB Password failed to update."; exit 1; }

echo "Updating HOST in settings.py..."
sed -i "s/#'HOST': 'your-rds-endpoint.amazonaws.com'/'HOST': '${rds_endpoint}'/g" $SETTINGS_FILE || { echo "DB Host Address failed to update."; exit 1; }

echo "Updating PORT in settings.py..."
sed -i "s/#'PORT': '5432'/'PORT': '5432'/g" $SETTINGS_FILE || { echo "Unable to uncomment PORT field."; exit 1; }

echo "Uncommenting curly bracket and sqlite fields in settings.py..."
sed -i "s/#\},/},/g" $SETTINGS_FILE || { echo "Unable to uncomment curly bracket."; exit 1; }
sed -i "s/#'sqlite': {/\ 'sqlite': {/g" $SETTINGS_FILE || { echo "Unable to uncomment sqlite field."; exit 1; }




#Create the tables in RDS and populate data:
echo "Creating database schema..." 
cd $PROJECT_DIR
python manage.py makemigrations account
python manage.py makemigrations payments
python manage.py makemigrations product
python manage.py migrate

#echo "Loading data into RDS database..."
#Migrate the data from SQLite file to RDS:
#python manage.py dumpdata --database=sqlite --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > datadump.json

#python manage.py loaddata datadump.json

#echo "Data loading completed successfully!"


# Start the Django development server
echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000