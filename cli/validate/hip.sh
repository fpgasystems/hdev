#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev validate hip --device $device_index
#example: /opt/hdev/cli/hdev validate hip --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
    exit
fi

#inputs
device_index=$2

#constants
#AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
#AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
#AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
#AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)
#AVED_VALIDATE_DESIGN="design.pdi"
#PARTITION_INDEX="0"
#PARTITION_TYPE="primary"

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#get rocm-bandwidth-test version
hip_version=$(dpkg -l | grep rocm-core | awk '{print $3}' | cut -d '.' -f 1-3)

eval "/opt/rocm-$hip_version/bin/rocm-bandwidth-test"

#echo ""

#author: https://github.com/jmoya82