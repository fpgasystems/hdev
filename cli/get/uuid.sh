#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil get partitions --device $device_index
#example: /opt/sgrt/cli/sgutil get partitions --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
if [ "$is_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2

#constants
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#all inputs must be provided
if [ "$device_index" = "" ]; then
    #echo ""
    print_echo="0"
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        current_uuid=""
        if [ "$device_type" = "asoc" ]; then
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
            current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
            #print
            if [ -n "$current_uuid" ]; then
                print_echo="1"
                if [ "$device_index" = "1" ]; then
                    echo ""
                fi
                echo "$device_index: $current_uuid"
            fi
        fi
    done
    if [ "$print_echo" = "1" ]; then
        echo ""
    fi
else
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
    current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
    #print
    if [ -n "$current_uuid" ]; then
        echo ""
        echo "$device_index: $current_uuid"
        echo ""
    fi
fi

#author: https://github.com/jmoya82