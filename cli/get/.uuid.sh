#!/bin/bash

#early exit
if [ "$is_asoc" = "0" ]; then
    exit
fi

#check on flags
valid_flags="-d --device --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line 2/2)
if [ ! "$flags_array" = "" ]; then
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if [ "$device_found" = "1" ] && [ ! "$device_type" = "asoc" ]; then
    echo ""
    echo "Sorry, this command is not available on device $device_index."
    echo ""
    exit
    fi
fi

#run
$CLI_PATH/get/uuid --device $device_index