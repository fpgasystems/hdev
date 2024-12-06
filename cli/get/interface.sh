#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev get interface

#constants
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
DEVICES_LIST_NIC="$CLI_PATH/devices_network"
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"

#check on DEVICES_LIST_FPGA
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_FPGA"
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NIC"

#get number of devices
MAX_DEVICES_NIC=$(grep -E "nic" $DEVICES_LIST_NIC | wc -l)
MAX_DEVICES_FPGA=$(grep -E "fpga|acap|asoc" $DEVICES_LIST_FPGA | wc -l)

ifconfig_devices=""
for device_index in $(seq 1 "$MAX_DEVICES_NIC"); do 
    DEVICE_i=$($CLI_PATH/get/get_nic_config "$device_index" 1 DEVICE)
    if [ -n "$DEVICE_i" ]; then  
        # Check for XDP
        output=$(ip link show "$DEVICE_i")
        xdp_string=""
        if echo "$output" | grep -q "xdp"; then
            xdp_string=" (xdp)"
        fi
        # Append to the list of devices
        ifconfig_devices+="${COLOR_ON1}${device_index}: $DEVICE_i$xdp_string${COLOR_OFF}\n"
    fi
done

#print
echo -e $ifconfig_devices

#author: https://github.com/jmoya82