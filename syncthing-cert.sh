#!/bin/bash

### This script updates Syncthing to use a Tailscale certificate
### This is easy to do as the .crt/.key can be used by Syncthing without changing format

source ./functions.sh

# Exit if Syncthing is not installed already
is_syncthing_installed;

# Install jq if not installed
is_jq_installed;

## Potential paths...
# /home/willjasen/.local/state/syncthing
# /mnt/tipi-app/runtipi/app-data/syncthing/data/config

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

# Check if the symbolic link points correctly
if [ "$(readlink -f ${CONFIG_FILEPATH}"/https-cert.pem")" = ${CERT_PATH}".crt" ]; then
    echo ${CONFIG_FILEPATH}"/https-cert.pem already points to "${CERT_PATH}".crt";
    if [ "$(readlink -f ${CONFIG_FILEPATH}"/https-key.pem")" = ${CERT_PATH}".key" ]; then
        echo ${CONFIG_FILEPATH}"/https-key.pem already points to "${CERT_PATH}".key";
        echo "Symbolic links are already correct, nothing more to do.";
        exit 0;
    fi;
fi;
echo "All symbolic links aren't correct, fixing...";

# Setup symbolic links for certificate and key
rm ${CONFIG_FILEPATH}"/https-cert.pem";
rm ${CONFIG_FILEPATH}"/https-key.pem";
ln -s ${CERT_PATH}".crt" ${CONFIG_FILEPATH}"/https-cert.pem";
ln -s ${CERT_PATH}".key" ${CONFIG_FILEPATH}"/https-key.pem";

# Restart the syncthing service
echo "Restarting the Syncthing service...";
systemctl restart syncthing@*.service;

echo "Tailscale certificate for Syncthing has been updated.";
