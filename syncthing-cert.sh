#!/bin/bash

### This script updates Syncthing to use a Tailscale certificate

# Exit if Syncthing is not installed already
if ! command -v syncthing &> /dev/null; then
    echo "Syncthing is not installed - exiting script.";
    exit 1;
else
    echo "Syncthing is installed, continuing...";
fi;

# Install jq if not installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed - installing...";
    apt update -qq; apt install jq -y;
else
    echo "jq is installed, continuing...";
fi;

CONFIG_FILEPATH="/home/willjasen/.local/state/syncthing";
CONFIG_FILE=$CONFIG_FILEPATH"/config.xml";
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Syncthing config file does not exist at $CONFIG_FILE... exiting script."
    exit 1
fi;
CERT_NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
CERT_PATH="/etc/ssl/tailscale/"$CERT_NAME;

# Use sed to change the "tls" key value within "gui" from "false" to "true"
sed -i 's/\(<gui[^>]*tls="\)false"/\1true"/' "$CONFIG_FILE";

# Setup symbolic links for certificate and key
rm ${CONFIG_FILEPATH}"/https-cert.pem";
rm ${CONFIG_FILEPATH}"/https-key.pem";
ln -s ${CERT_PATH}".crt" ${CONFIG_FILEPATH}"/https-cert.pem";
ln -s ${CERT_PATH}".key" ${CONFIG_FILEPATH}"/https-key.pem";

# Restart the syncthing service
systemctl restart syncthing@*.service;

echo "Tailscale certificate for Syncthing has been updated.";
