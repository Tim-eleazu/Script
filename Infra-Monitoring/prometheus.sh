#!/bin/bash

# Prometheus Installation
echo "Adding prometheus and node_exporter users..."
sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter

echo "Creating necessary directories..."
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

echo "Changing ownership of directories..."
sudo chown prometheus:prometheus /var/lib/prometheus

echo "Downloading Prometheus..."
cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1.linux-amd64.tar.gz

echo "Extracting Prometheus package..."
tar -xvf prometheus-2.31.1.linux-amd64.tar.gz
cd prometheus-2.31.1.linux-amd64

echo "Moving configuration files and binaries..."
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo mv prometheus /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus

# Create system service file
SERVICE_FILE=/etc/systemd/system/prometheus.service

echo "Creating Prometheus service file..."
sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon and starting Prometheus service..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "Prometheus installation and service setup completed."