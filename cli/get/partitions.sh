#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil get partitions --device $device_index --type $boot_type
#example: /opt/sgrt/cli/sgutil get partitions --device             1 --type    primary

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
if [ "$is_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2
boot_type=$4

#constants
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#all inputs must be provided
if [ "$device_index" = "none" ]; then
    #echo ""
    print_echo="0"
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        partitions=""
        if [ "$device_type" = "asoc" ]; then
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            partitions=$(ami_tool cfgmem_info -d $upstream_port -t $boot_type | awk '/^Partition/ {flag=1; next} flag && /^[0-9]/' | wc -l)
            #check on partitions
            if [ "$partitions" = "0" ]; then
                partitions=""
            else
                partitions=$((partitions - 1))
            fi
            #print
            if [ -n "$partitions" ]; then
                print_echo="1"
                if [ "$device_index" = "1" ]; then
                    echo ""
                fi
                echo "$device_index: [0 ... $partitions]"
            fi
        #else
        #    #print
        #    echo "$device_index: "
        fi
    done
    if [ "$print_echo" = "1" ]; then
        echo ""
    fi
else
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    partitions=$(ami_tool cfgmem_info -d $upstream_port -t $boot_type | awk '/^Partition/ {flag=1; next} flag && /^[0-9]/' | wc -l)
    #partitions=$((partitions - 1))
    #check on partitions
    if [ "$partitions" = "0" ]; then
        partitions=""
    else
        partitions=$((partitions - 1))
    fi
    #print
    if [ -n "$partitions" ]; then
        echo ""
        echo "$device_index: [0 ... $partitions]"
        echo ""
    fi
fi

#author: https://github.com/jmoya82