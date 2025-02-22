#!/bin/bash

# Check if the script is running as root
function check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
    fi
}

# Call the function to check root privileges
check_root

# Global variables
HONEYGAIN_EMAIL="example_honeygain_email"
HONEYGAIN_PASSWORD="example_password"
PAWNS_EMAIL="example_pawns_email"
PAWNS_PASSWORD="example_password"
CLIENT_NAME="example_client_name"

# Install the honeygain service
function install-honeygain-service() {
    echo "[Unit]
Description=Honeygain Service
After=network.target

[Service]
ExecStart=honeygain -tou-accept -email \"${HONEYGAIN_EMAIL}\" -pass \"${HONEYGAIN_PASSWORD}\" -device \"${CLIENT_NAME}\"
Restart=always
RestartSec=5
User=root
Group=root

[Install]
WantedBy=default.target" >>/etc/systemd/system/honeygain.service
    systemctl daemon-reload
    systemctl enable honeygain.service
    systemctl start honeygain.service
}

# Install the honeygain service
install-honeygain-service

# Install the pawns service
function install-pawns-service() {
    echo "[Unit]
Description=Pawns App Service
After=network.target

[Service]
ExecStart=pawns-cli -email \"${PAWNS_EMAIL}\" -password \"${PAWNS_PASSWORD}\" -device-name \"${CLIENT_NAME}\" -device-id \"${CLIENT_NAME}\" -accept-tos
Restart=always
RestartSec=5
User=root
Group=root

[Install]
WantedBy=default.target" >> /etc/systemd/system/pawns.service
    systemctl daemon-reload
    systemctl enable pawns.service
    systemctl start pawns.service
}

# Install the pawns service
install-pawns-service