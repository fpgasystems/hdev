#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

# Check for correct number of arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 host_config_idx"
  exit 1
fi

get_config_string() {
  local num="$1"
  printf "%0${MAX_STR_LENGTH}d" "$num"
}

#inputs
CONFIG_IDX="$1"
HOST_CONFIG="host_config_${CONFIG_IDX}"

#constants
MAX_STR_LENGTH=3

#get configuration string
config_string=$(get_config_string "$CONFIG_IDX")

#ensure running config_add
if [ -f "./configs/host_config_000" ]; then
    ./config_add
    config_string="001"
fi

#check on host_config
if [ ! -f "./configs/host_config_$config_string" ]; then
    echo "Host configuration not found!"
    exit 1
fi

# Print contents
cat kn.cfg
echo

echo "===== $DEVICE_CONFIG ====="
cat "./configs/device_config"
echo

echo "===== $HOST_CONFIG ====="
cat "./configs/host_config_$config_string"