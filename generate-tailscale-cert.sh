#!/bin/bash

# This script generates a certificate from tailscale in "/etc/ssl/tailscale"

# Install jq if not installed
which jq || apt update; apt install jq -y;

# Generate certificate
CERT_DIR=/etc/ssl/tailscale;
mkdir -p $CERT_DIR;
cd $CERT_DIR;
NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)";
tailscale cert "${NAME}";
