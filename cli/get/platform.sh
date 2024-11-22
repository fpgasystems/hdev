#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$is_acap" = "0" ] && [ "$is_fpga" = "0" ]; then
    exit
fi

#constants
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on build server
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
if [ "$is_build" = "1" ]; then
#    echo ""
#    ls -l $XILINX_PLATFORMS_PATH/ | grep '^d' | awk '{print $NF}'
#    echo ""
    exit
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
        if [ -n "$platform" ]; then
            echo "$device_index: $platform"
        fi
    done
    echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        #$CLI_PATH/sgutil get platform -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/sgutil get platform -h
        exit
    fi
    #print
    platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
    echo ""
    echo "$device_index: $platform"
    echo ""
fi