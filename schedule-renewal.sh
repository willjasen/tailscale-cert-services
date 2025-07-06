#!/bin/bash

### This script handles the scheduling of a Tailscale certificate renewal via cron

# Check for required parameter
if [ -z "$1" ]; then
  echo "Usage: $0 [--tailscale|--proxmox]"
  exit 1
fi

# Set CERT_SCRIPT based on parameter
case "$1" in
  --tailscale)
    export CERT_SCRIPT=/opt/tailscale-cert-services/generate-tailscale-cert.sh
    ;;
  --proxmox)
    export CERT_SCRIPT=/opt/tailscale-cert-services/proxmox-cert.sh
    ;;
  *)
    echo "Invalid parameter: $1"
    echo "Usage: $0 [--tailscale|--proxmox]"
    exit 1
    ;;
esac

source ./functions.sh;

# Setup cron schedule
# This cron schedule happens at 4:00 am on the first of every month
export CRON_JOB="0 4 1 * * cd /opt/tailscale-cert-services && git pull && $CERT_SCRIPT"
echo "Checking crontab... "
(crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -;
