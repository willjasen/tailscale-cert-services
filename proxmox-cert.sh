#!/bin/bash

### This script updates Proxmox to use a Tailscale certificate
### This is easy to do as the .crt/.key can be used by Proxmox without changing format

source ./functions.sh;

# Exit if Proxmox is not installed already
is_proxmox_installed;

# Run main script
./generate-tailscale-cert.sh

# Set the certificate
pvenode cert set "/etc/ssl/tailscale/${CERT_NAME}.crt" "/etc/ssl/tailscale/${CERT_NAME}.key" --force --restart