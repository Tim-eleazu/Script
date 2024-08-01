#!/bin/bash

# Create the alertmanager system user
sudo useradd --no-create-home --shell /bin/false alertmanager

# Create the /etc/alertmanager directory
sudo mkdir -p /etc/alertmanager

# Download Alertmanager
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz

# Extract the files
tar -xvf alertmanager-0.26.0.linux-amd64.tar.gz

# Move the binaries
cd alertmanager-0.26.0.linux-amd64
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/

# Set the ownership of the binaries
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

# Move the configuration file into the /etc/alertmanager directory
sudo mv alertmanager.yml /etc/alertmanager/

# Set the ownership of the /etc/alertmanager directory
sudo chown -R alertmanager:alertmanager /etc/alertmanager/

# Create the alertmanager.service file for systemd
cat <<EOF | sudo tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \\
    --config.file=/etc/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
EOF

# Instructions for updating Prometheus configuration
echo "Please update your Prometheus configuration file to include Alertmanager, then reload systemd and start the services."

# The script ends here. The user is advised to manually edit Prometheus configuration and manage service starts. 
