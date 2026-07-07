#!/bin/bash

DEVICES_LIST=$1

if [[ -f "$DEVICES_LIST" ]]; then
  # Print if the first fpga/acap is valid
  device_1=$(head -n 1 "$DEVICES_LIST")
  upstream_port_1=$(echo "$device_1" | awk '{print $2}') 
  if ! lspci | grep -qz $upstream_port_1; then
    echo "ERROR: Could not find fpga in lspci. Contact the cluster maintainer"
    exit 1
  fi
else
  #DEVICES_LIST does not exist
  echo "ERROR: 'devices_acap_fpga' does not exist for this node. Contact the cluster maintainer"
  exit 1
fi
