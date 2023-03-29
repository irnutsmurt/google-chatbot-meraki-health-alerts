#!/bin/bash

# Set the account username
username="meraki-alerts"

# Create the user with no login shell
sudo useradd --system --no-create-home --shell /usr/sbin/nologin $username

# Create a log directory for the service and set ownership
sudo mkdir -p /var/log/meraki-alerts
sudo chown $username:$username /var/log/meraki-alerts

# Create a working directory for the service and set ownership
sudo mkdir -p /opt/merakialerts
sudo chown $username:$username /opt/merakialerts

echo "Service account $username created."
