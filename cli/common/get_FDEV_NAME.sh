#!/bin/bash

CLI_PATH=$1
device_index=$2

platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

echo "$FDEV_NAME"