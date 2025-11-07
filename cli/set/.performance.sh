#!/bin/bash

#early exit
if [ "$is_gpu" = "0" ]; then
    exit 1
fi

valid_flags="-d --device -v --value -h --help"
#command_run $command_arguments_flags"@"$valid_flags
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    set_performance_help
else
    #device
    result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')

    #value
    result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
    value_found=$(echo "$result" | sed -n '1p')
    value=$(echo "$result" | sed -n '2p')

    #check on device
    if [ "$device_found" = "1" ]; then
        device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    fi

    #check on value
    if [[ "$value" != "low" && "$value" != "high" && "$value" != "auto" ]]; then
        echo ""
        echo $CHECK_ON_PERFORMANCE_ERR_MSG
        echo ""
        exit
    fi
fi

#run
$CLI_PATH/set/performance --value $value --device $device_index