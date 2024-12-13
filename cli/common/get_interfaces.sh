#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1

#constants
DEVICES_LIST_NIC="$CLI_PATH/devices_network"
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"

#check on DEVICES_LIST_FPGA
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_FPGA"
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NIC"

#get number of devices
MAX_DEVICES_NIC=$(grep -E "nic" $DEVICES_LIST_NIC | wc -l)
MAX_DEVICES_FPGA=$(grep -E "fpga|acap|asoc" $DEVICES_LIST_FPGA | wc -l)

#NICs
interfaces=()
for device_index in $(seq 1 "$MAX_DEVICES_NIC"); do 
    # Port 1
    DEVICE_i_1=$($CLI_PATH/get/get_nic_config "$device_index" 1 DEVICE)

    if [ -n "$DEVICE_i_1" ]; then  
        interfaces+=("$DEVICE_i_1")
    fi
    
    # Port 2
    DEVICE_i_2=$($CLI_PATH/get/get_nic_config "$device_index" 2 DEVICE)
    if [ -n "$DEVICE_i_2" ]; then  
        interfaces+=("$DEVICE_i_2")
    fi
done

#Adaptvie Devices
for device_index in $(seq 1 "$MAX_DEVICES_FPGA"); do 
    id_i=$($CLI_PATH/get/get_fpga_device_param $device_index id)
    if [ -n "$id_i" ]; then  
        ip=$($CLI_PATH/get/get_fpga_device_param $device_index IP)
        ip1=$(echo "$ip" | cut -d'/' -f1)
        ip2=$(echo "$ip" | cut -d'/' -f2)
        
        # Port 1
        DEVICE_i_1=$(ifconfig | grep -B1 "$ip1" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
        if [ -n "$DEVICE_i_1" ]; then  
            interfaces+=("$DEVICE_i_1")
        fi
        
        # Port 2
        DEVICE_i_2=$(ifconfig | grep -B1 "$ip2" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
        if [ -n "$DEVICE_i_2" ]; then  
            interfaces+=("$DEVICE_i_2")
        fi
    fi
done

#print
for device in "${interfaces[@]}"; do
    echo "$device"
done

#author: https://github.com/jmoya82