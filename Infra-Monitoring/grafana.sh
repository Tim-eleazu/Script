#!/bin/bash

# This script installs Grafana on a Debian/Ubuntu system.

# Exit immediately if a command exits with a non-zero status.
set -e

# Step 1: Download and add the Grafana GPG key
echo "Adding the Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Step 2: Add the Grafana repository to APT sources
echo "Adding the Grafana repository..."
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Step 3: Refresh APT cache
echo "Updating package lists..."
sudo apt update

# Step 4: Install Grafana
echo "Installing Grafana..."
sudo apt install grafana -y

# Step 5: Start the Grafana server
echo "Starting Grafana server..."
sudo systemctl start grafana-server

# Step 6: Check the status of the Grafana service
echo "Checking Grafana server status..."
sudo systemctl status grafana-server | cat

echo "Grafana installation completed successfully."