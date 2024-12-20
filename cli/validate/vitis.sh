#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [[ "$is_build" = "1" ]] || ([[ "$is_acap" = "0" ]] && [[ "$is_fpga" = "0" ]]); then
    exit
fi

#constants
CHECK_ON_REVERT_ERR_MSG="Please, revert your device first."
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

#get username
username=$USER

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on valid XRT version
#if [ ! -d $XRT_PATH ]; then
#    echo ""
#    echo "Please, source a valid XRT and Vitis version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid XRT version
xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)

if [ -z "$xrt_version" ]; then #if [ -z "$(echo $xrt_version)" ]; then
    echo ""
    echo "Please, source a valid XRT version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
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
    #header (1/2)
    echo ""
    echo "${bold}hdev validate vitis${normal}"
    #device_dialog
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    else
        echo ""
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
    fi
    #check on workflow
    workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
    if [ ! "$workflow" = "vitis" ]; then
        echo ""
        echo $CHECK_ON_REVERT_ERR_MSG
        echo ""
        exit
    fi
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        #$CLI_PATH/hdev validate vitis -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #check on workflow
    workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
    if [ ! "$workflow" = "vitis" ]; then
        echo ""
        echo $CHECK_ON_REVERT_ERR_MSG
        echo ""
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}hdev validate vitis${normal}"
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/hdev validate vitis -h
        exit
    fi    
fi

#validate
echo ""
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf=$(echo "$upstream_port" | sed 's/0$/1/')
$XRT_PATH/bin/xbutil validate --device $bdf
echo ""
