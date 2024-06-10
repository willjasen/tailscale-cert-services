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
if_jq () {
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
