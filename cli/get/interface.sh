#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev get interface

#constants
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
DEVICES_LIST_NIC="$CLI_PATH/devices_network"
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"

#check on DEVICES_LIST_FPGA
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_FPGA"
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NIC"

#get number of devices
MAX_DEVICES_NIC=$(grep -E "nic" $DEVICES_LIST_NIC | wc -l)
MAX_DEVICES_FPGA=$(grep -E "fpga|acap|asoc" $DEVICES_LIST_FPGA | wc -l)

#NICs
nic_devices=()
for device_index in $(seq 1 "$MAX_DEVICES_NIC"); do 
    # Port 1
    DEVICE_i_1=$($CLI_PATH/get/get_nic_config "$device_index" 1 DEVICE)
    if [ -n "$DEVICE_i_1" ]; then  
        # Check for XDP
        output=$(ip link show "$DEVICE_i_1")
        xdp_string=""
        if echo "$output" | grep -q "xdp"; then
            xdp_string=" (xdp)"
        fi
        # Append to the list of devices (add to array as a single element)
        nic_devices+=("${COLOR_ON1}${device_index}: $DEVICE_i_1$xdp_string${COLOR_OFF}")
    fi
    
    # Port 2
    DEVICE_i_2=$($CLI_PATH/get/get_nic_config "$device_index" 2 DEVICE)
    if [ -n "$DEVICE_i_2" ]; then  
        # Check for XDP
        output=$(ip link show "$DEVICE_i_2")
        xdp_string=""
        if echo "$output" | grep -q "xdp"; then
            xdp_string=" (xdp)"
        fi
        # Append to the list of devices (add to array as a single element)
        nic_devices+=("${COLOR_ON1}   $DEVICE_i_2$xdp_string${COLOR_OFF}")
    fi
done

#legend 1
if [ -n "$nic_devices" ]; then
    legend_nic="${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
fi

#Adaptvie Devices
fpga_devices=()
for device_index in $(seq 1 "$MAX_DEVICES_FPGA"); do 
    id_i=$($CLI_PATH/get/get_fpga_device_param $device_index id)
    if [ -n "$id_i" ]; then  
        ip=$($CLI_PATH/get/get_fpga_device_param $device_index IP)
        ip1=$(echo "$ip" | cut -d'/' -f1)
        ip2=$(echo "$ip" | cut -d'/' -f2)
        
        # Port 1
        DEVICE_i_1=$(ifconfig | grep -B1 "$ip1" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
        if [ -n "$DEVICE_i_1" ]; then  
            # Check for XDP
            output=$(ip link show "$DEVICE_i_1")
            xdp_string=""
            if echo "$output" | grep -q "xdp"; then
                xdp_string=" (xdp)"
            fi
            # Append to the list of devices (add to array as a single element)
            fpga_devices+=("${COLOR_ON2}${device_index}: $DEVICE_i_1$xdp_string${COLOR_OFF}")
        fi
        
        # Port 2
        DEVICE_i_2=$(ifconfig | grep -B1 "$ip2" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
        if [ -n "$DEVICE_i_2" ]; then  
            # Check for XDP
            output=$(ip link show "$DEVICE_i_2")
            xdp_string=""
            if echo "$output" | grep -q "xdp"; then
                xdp_string=" (xdp)"
            fi
            # Append to the list of devices (add to array as a single element)
            fpga_devices+=("${COLOR_ON2}${device_index}: $DEVICE_i_2$xdp_string${COLOR_OFF}")
        fi
    fi
done

#legend 2
if [ -n "$fpga_devices" ]; then
    legend_fpga="${bold}${COLOR_ON2}Adaptive Devices${COLOR_OFF}${normal}"
fi

#remove the trailing newline
#nic_devices=$(echo -e "$nic_devices" | sed '$ s/\\n$//')
#fpga_devices=$(echo -e "$fpga_devices" | sed '$ s/\\n$//')

# Remove the last newline
#nic_devices=$(echo -e "$nic_devices" | sed '$d')
#fpga_devices=$(echo -e "$fpga_devices" | sed '$d')

#print
if [ -n "$nic_devices" ] && [ ! -n "$fpga_devices" ]; then  
    echo ""
    for device in "${nic_devices[@]}"; do
        echo -e "$device"
    done
    echo ""
    echo -e $legend_nic
    echo ""
elif [ ! -n "$nic_devices" ] && [ -n "$fpga_devices" ]; then  
    echo ""
    for device in "${fpga_devices[@]}"; do
        echo -e "$device"
    done
    echo ""
    echo -e $legend_fpga
    echo ""
else
    echo ""
    for device in "${nic_devices[@]}"; do
        echo -e "$device"
    done
    for device in "${fpga_devices[@]}"; do
        echo -e "$device"
    done
    echo ""
    echo -e $legend_nic" "$legend_fpga
    echo ""
fi

#author: https://github.com/jmoya82