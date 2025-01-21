#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

device_index=$1

id=$($CLI_PATH/get/get_fpga_device_param $device_index id)
#print table
if [ -n "$id" ]; then
    workflow=$($CLI_PATH/get/workflow -d $device_index)
    workflow=$(echo "$workflow" $device_index | cut -d' ' -f2 | sed '/^\s*$/d')
    if [ $workflow = "onicxdp" ]; then
        #get interface name
        ip=$($CLI_PATH/get/get_fpga_device_param $device_index IP)
        ip0=$(echo "$ip" | cut -d'/' -f1)
        iface_name_0=$(ifconfig | grep -B1 "$ip0" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
        
        #kill xdp program (similar to hdev program xdp --stop $iface_name_0)
        echo "${bold}Detaching XDP/eBPF function:${normal}"
        echo ""
        echo "sudo $CLI_PATH/program/xdp_detach $iface_name_0"
        echo ""            
        sudo $CLI_PATH/program/xdp_detach $iface_name_0
    fi
fi