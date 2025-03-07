#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev set performance --value $value --device $device_index
#example: /opt/hdev/cli/hdev set performance --value    low --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
if [ "$is_gpu" = "0" ]; then
    exit 1
fi

#inputs
value=$2
device_index=$4

#all inputs must be provided (device index can be empty)
if [ "$value" = "" ]; then
    exit
fi

if [ "$device_index" = "" ]; then
    #performance level is applied to all GPUs
    sudo /opt/rocm/bin/rocm-smi --setperflevel "$value" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        sleep 2
    fi
else
    device_index=$((device_index - 1))
    sudo /opt/rocm/bin/rocm-smi --setperflevel "$value" -d $device_index > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        sleep 2
    fi
fi