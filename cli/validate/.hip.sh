#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
    exit
fi

#constants
DEVICES_LIST="$CLI_PATH/devices_gpu"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#verify rocm/rocm-bandwidth-test version (similar to login_deployment.sh)
hip_version=$(dpkg -l | grep rocm-core | awk '{print $3}' | cut -d '.' -f 1-3)
if [[ ! -x /opt/rocm-$hip_version/bin/rocm-bandwidth-test ]]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check on flags
valid_flags="-d --device --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "gpu" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#checks (command line 2/2)
if [ ! "$flags_array" = "" ]; then
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
fi

#dialogs
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $HIP_TAG)${normal}"
#echo ""
if [ "$multiple_devices" = "0" ]; then
    device_found="1"
    device_index="1"
else
    echo ""
    device_dialog_gpu "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
fi

#run
$CLI_PATH/validate/hip --device $device_index