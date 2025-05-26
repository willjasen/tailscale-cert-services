#!/bin/bash

## This script generates a certificate from tailscale into $CERT_DIR
## and sets up a cron job to renew it on the first of the month at 3 am

source ./functions.sh;
update_repo;
source ./functions.sh;

# Exit if Tailscale is not installed already
is_tailscale_installed;

# Install jq if not installed
is_jq_installed;

# Variables
export CERT_DIR=/etc/ssl/tailscale;
export CERT_SCRIPT=/opt/tailscale-cert-services/generate-tailscale-cert.sh;
export THIS_SCRIPT_PATH=$(realpath "$0");
export CRON_JOB="0 4 1 * * $CERT_SCRIPT;";
export CERT_NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
if [[ $USER == "root" ]]; then export USER_FOR_PERMISSION=root; else export USER_FOR_PERMISSION=willjasen; fi;

# Generate Tailscale certificate
# Access is given to the user specified
echo "Attempting to generate Tailscale certificate for "$CERT_NAME;
mkdir -p $CERT_DIR;
cd $CERT_DIR;
tailscale cert "${CERT_NAME}";
chown $USER_FOR_PERMISSION:$USER_FOR_PERMISSION $CERT_NAME".crt";
chown $USER_FOR_PERMISSION:$USER_FOR_PERMISSION $CERT_NAME".key";

# Make a PFX
make_pfx;

# Setup cron schedule
# This cron schedule happens at 4:00 am on the first of every month
echo "Checking crontab... ";
(crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -;
