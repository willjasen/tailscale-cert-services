#!/bin/bash

### This script updates Proxmox to use a Tailscale certificate
### This is easy to do as the .crt/.key can be used by Proxmox without changing format

source ./functions.sh;

# Exit if Proxmox is not installed already
is_proxmox_installed;

# Run main script
./generate-tailscale-cert.sh

# Set the certificate
TS_HOST_NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
pvenode cert set "/etc/ssl/tailscale/${TS_HOST_NAME}.crt" "/etc/ssl/tailscale/${TS_HOST_NAME}.key" --force --restart

# Schedule renewal for Proxmox
echo "Scheduling Proxmox certificate renewal...";
./schedule-renewal.sh --proxmox;
