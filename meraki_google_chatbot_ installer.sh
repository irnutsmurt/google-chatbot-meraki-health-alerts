#!/bin/bash

# Prompt the user for the service account name
read -p "Enter the service account username: " username

# Create the user with no login shell
sudo useradd --system --no-create-home --shell /usr/sbin/nologin $username

# Create a log directory for the service and set ownership
sudo mkdir -p /var/log/meraki-alerts
sudo chown $username:$username /var/log/meraki-alerts

# Check if required files are present
if [ ! -f main.py ] || [ ! -f meraki.py ] || [ ! -f googlechat.py ] || [ ! -f config.ini ]; then
    echo "Error: Required files (main.py, meraki.py, googlechat.py, and config.ini) not found in the current directory."
    exit 1
fi

# Get the current working directory
current_dir=$(pwd)

# If not in a home directory, change the owner of the files to the service account
if [[ ! $current_dir =~ ^/home ]]; then
    sudo chown -R $username:$username $current_dir
fi

# Check if all the required files are present
if [[ -f "main.py" && -f "googlechat.py" && -f "meraki.py" && -f "config.ini" && -f "requirements.txt" ]]; then
    echo "All required files are present."
else
    echo "Some required files are missing. Please make sure main.py, googlechat.py, meraki.py, config.ini, and requirements.txt are in the current directory."
    exit 1
fi

# Install the required Python packages
pip3 install -r requirements.txt

# Copy the systemd service file to the proper location
sudo cp meraki-alerts.service /etc/systemd/system/meraki-alerts.service

# Replace the username in the systemd service file
sudo sed -i "s/User=<your-user>/User=$username/g" /etc/systemd/system/meraki-alerts.service

# Set the WorkingDirectory and ExecStart paths in the systemd service file
sudo sed -i "s|WorkingDirectory=<your-working-dir>|WorkingDirectory=$current_dir|g" /etc/systemd/system/meraki-alerts.service
sudo sed -i "s|ExecStart=<your-script-path>|ExecStart=/usr/bin/python3 $current_dir/main.py|g" /etc/systemd/system/meraki-alerts.service

# Replace the username in the systemd service file
sudo sed -i "s/User=<your-user>/User=$username/g" /etc/systemd/system/meraki-alerts.service

# Prompt the user for Meraki API key, network ID, and Google Chat webhook
read -p "Enter your Meraki API key: " meraki_api_key
read -p "Enter your Meraki network ID: " network_id
read -p "Enter your Google Chat webhook URL: " webhook_url

# Check if the webhook URL has a % in it and add a second % if needed
webhook_url=$(echo "$webhook_url" | sed 's/%/%%/g')

# Update the config.ini file with the provided information
echo "[meraki]
api_key = $meraki_api_key
network_id = $network_id

[google_chat]
webhook_url = $webhook_url" > config.ini

echo "Installation completed. Remember to start and enable the service using:"
echo "sudo systemctl start meraki-alerts.service"
echo "sudo systemctl enable meraki-alerts.service"
echo "sudo systemctl status meraki-alerts.service"
