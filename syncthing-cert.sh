#!/bin/bash

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

CONFIG_FILE="~/.local/state/syncthing/config.xml";
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Syncthing config file does not exist at $CONFIG_FILE... exiting script."
    exit 1
fi;

CERT_NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
CERT_PATH="/etc/ssl/tailscale/"$CERT_NAME;

# Lines to be added
tls_cert_file="<tlsCertFile>"$CERT_PATH".crt</tlsCertFile>";
tls_key_file="<tlsKeyFile>"$CERT_PATH".key</tlsKeyFile>";

# Use sed to insert the lines after the <gui> tag
sed -i "/<gui>/a \\
    $tls_cert_file\\
    $tls_key_file" "$CONFIG_FILE";

echo "Tailscale TLS certificate and key paths added to Syncthing config.";

echo "Outputting the lines for verification...";
cat $CONFIG_FILE | grep "<tlsCertFile>";
cat $CONFIG_FILE | grep "<tlsKeyFile>";
