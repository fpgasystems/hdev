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

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#constants
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)
SECONDS_COUNT=5
SECONDS_INCREASE=0.2
TMP_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)

#get rocm-bandwidth-test version
hip_version=$(dpkg -l | grep rocm-core | awk '{print $3}' | cut -d '.' -f 1-3)

#mimic rocm-bandwidth-test
iterations=$(echo "$SECONDS_COUNT / $SECONDS_INCREASE" | bc)
for ((i=0; i<iterations; i++)); do
    echo -n "."
    sleep "$SECONDS_INCREASE"
done

#run bandwith test
$ROCM_PATH-$hip_version/bin/rocm-bandwidth-test > $TMP_PATH/rocm_bandwidth_test_output
cat "$TMP_PATH/rocm_bandwidth_test_output"

#remove temporal file
rm -f $TMP_PATH/rocm_bandwidth_test_output

#author: https://github.com/jmoya82