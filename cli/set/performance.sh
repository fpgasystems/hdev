#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev set performance --value $value
#example: /opt/hdev/cli/hdev set performance --value          1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
if [ "$is_gpu" = "0" ]; then
    exit 1
fi

#inputs
value=$2

#all inputs must be provided
if [ "$value" = "" ]; then
    exit
fi

device="1"

sudo rocm-smi --setperflevel "$value" -d $device > /dev/null 2>&1
if [ $? -eq 0 ]; then
    #echo "Performance level set to ${bold}$value${normal} on device ${bold}$device!${normal}"
    sleep 2
fi