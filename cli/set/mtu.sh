#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil set mtu --device $device_index --port $port_index --value $mtu_value
#example: /opt/sgrt/cli/sgutil set mtu --device     enp35s0f0 --port           1 --value       1982

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#inputs
device_index=$2
port_index=$4
mtu_value=$6

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$mtu_value" = "" ]; then
    exit
fi

#constants
MTU_MAX=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MAX)
MTU_MIN=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MIN)

calculate_closest_mtu() {
    local desired_mtu=$1
    local header_size=$2
    local base=$3

    # Calculate the closest multiple of 64
    local closest_mtu=$(( ((desired_mtu - header_size) + base - 1) / base * base ))
    local closest_mtu=$(( closest_mtu + header_size ))

    echo $closest_mtu
}

#constants
IPV6_HEADER_SIZE=40
PAYLOAD_MULTIPLES=64

#get closest MTU for a payload multiple
mtu_value=$(calculate_closest_mtu $mtu_value $IPV6_HEADER_SIZE $PAYLOAD_MULTIPLES)

#verify MTU is between valid range
if [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
    exit
fi

#get interface_name
#NETWORKING_PORT_INDEX="1"
interface_name=$($CLI_PATH/get/get_nic_config $device_index $port_index DEVICE)
if [ "$interface_name" = "" ]; then
    echo ""
    echo "Please, choose a valid network device."
    echo ""
else
    #set mtu_value
    sudo ifconfig $interface_name mtu $mtu_value up > /dev/null 2>&1

    # Verify if the MTU change was successful
    new_mtu=$(ifconfig $interface_name | grep -oP 'mtu \K\d+')

    #print message
    if [ "$new_mtu" -eq "$mtu_value" ]; then
        echo ""
        echo "$interface_name MTU was set to $mtu_value bytes!"
        echo ""
    fi
fi