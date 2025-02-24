#!/bin/sh

### Functions are within here

# Exit if Tailscale is not installed already
is_tailscale_installed () {
  if ! command -v tailscale &> /dev/null; then
    echo "Tailscale is not installed - exiting script.";
    exit 1;
  else
    echo "Tailscale is installed, continuing...";
  fi;
};

# Install jq if not installed
is_jq_installed () {
  if ! command -v jq &> /dev/null; then
    echo "jq is not installed - installing...";
    apt update -qq; apt install jq -y;
  else
    echo "jq is installed, continuing...";
  fi;
};

# Exit if Syncthing is not installed already
is_syncthing_installed () {
  if ! command -v syncthing &> /dev/null; then
    echo "Syncthing is not installed - exiting script.";
    exit 1;
  else
    echo "Syncthing is installed, continuing...";
  fi;
};

# Exit if Proxmox is not installed
is_proxmox_installed () {
  if ! command -v pveproxy &> /dev/null; then
    echo "Proxmox is not installed - exiting script.";
    exit 1;
  else
    echo "Proxmox is installed, continuing...";
  fi;
};

# Update this repo
update_repo () {
  cd /opt/tailscale-cert-services;
  git pull;
};

# Make a PFX of the certificate and key files
make_pfx () {

  # Find the .crt and .key files
  CRT_FILE=$(find /etc/ssl/tailscale -type f -name "*.crt" | head -n 1)
  KEY_FILE=$(find /etc/ssl/tailscale -type f -name "*.key" | head -n 1)

  # Check if files are found
  if [[ -z "$CRT_FILE" || -z "$KEY_FILE" ]]; then
      echo "Error: .crt or .key file not found in /etc/ssl/tailscale"
      exit 1
  fi

  # Extract the root name (filename without extension)
  ROOT_NAME=$(basename "$CRT_FILE" .crt)

  # Create the .pfx file using the root name
  PFX_FILE="/etc/ssl/tailscale/${ROOT_NAME}.pfx"

  # Generate the .pfx file
  openssl pkcs12 -export -out "$PFX_FILE" -inkey "$KEY_FILE" -in "$CRT_FILE" -passout pass:yourpassword

  # Verify the output
  if [[ $? -eq 0 ]]; then
      echo "PFX file created successfully: $PFX_FILE"
  else
      echo "Error creating PFX file"
  fi

}