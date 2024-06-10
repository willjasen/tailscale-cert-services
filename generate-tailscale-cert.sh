#!/bin/bash

## This script generates a certificate from tailscale into $CERT_DIR
## and sets up a cron job to renew it once per month

# Exit if Tailscale is not installed already
if ! command -v tailscale &> /dev/null; then
    echo "Tailscale is not installed - exiting script.";
    exit 1;
else
    echo "Tailscale is installed, continuing...";
fi;

# Install jq if not installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed - installing...";
    apt update -qq; apt install jq -y;
else
    echo "jq is installed, continuing...";
fi;

# Variables
CERT_DIR=/etc/ssl/tailscale;
CERT_SCRIPT=/opt/generate-tailscale-cert.sh;
THIS_SCRIPT_PATH=$(realpath "$0");
CRON_JOB="0 3 1 * * $CERT_SCRIPT";
CERT_NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
USER_FOR_PERMISSION=willjasen;

# Generate Tailscale certificate
# Access is given to the 
mkdir -p $CERT_DIR;
cd $CERT_DIR;
tailscale cert "${CERT_NAME}";
chown $USER_FOR_PERMISSION:$USER_FOR_PERMISSION $CERT_NAME".crt";
chown $USER_FOR_PERMISSION:$USER_FOR_PERMISSION $CERT_NAME".key";

# Setup cron schedule
# This cron schedule happens at 3:00 am on the first of every month
cp $THIS_SCRIPT_PATH $CERT_SCRIPT;
chmod u+x $CERT_SCRIPT;
(crontab -l | grep -F "$CRON_JOB") || (crontab -l;
echo "$CRON_JOB") | crontab -;
