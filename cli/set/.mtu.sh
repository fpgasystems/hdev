#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

valid_flags="-d --device -p --port -v --value -h --help"
#command_run $command_arguments_flags"@"$valid_flags
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    set_mtu_help
else
    #device
    result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #port
    result="$("$CLI_PATH/common/port_dialog_check" "${flags_array[@]}")"
    port_found=$(echo "$result" | sed -n '1p')
    port_index=$(echo "$result" | sed -n '2p')
    #value
    result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
    mtu_value_found=$(echo "$result" | sed -n '1p')
    mtu_value=$(echo "$result" | sed -n '2p')

    #device and port are binded
    if [ "$device_found" = "1" ] && [ "$port_found" = "0" ] && [ "$mtu_value_found" = "0" ]; then
        device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices_networking" "$MAX_DEVICES_NETWORKING" "${flags_array[@]}"
    elif [ "$device_found" = "0" ] && [ "$port_found" = "1" ] && [ "$mtu_value_found" = "0" ]; then
        echo ""
        echo $CHECK_ON_DEVICE_ERR_MSG
        echo ""
        exit
    elif [ "$device_found" = "0" ] && [ "$port_found" = "0" ] && [ "$mtu_value_found" = "1" ]; then
        value_check "$CLI_PATH" "$MTU_MIN" "$MTU_MAX" "MTU" "${flags_array[@]}"
        echo ""
        echo $CHECK_ON_DEVICE_ERR_MSG
        echo ""
        exit
    fi
    
    #natural order
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices_networking" "$MAX_DEVICES_NETWORKING" "${flags_array[@]}"
    port_check "$CLI_PATH" "$CLI_NAME" "$device_index" "${flags_array[@]}"
    value_check "$CLI_PATH" "$MTU_MIN" "$MTU_MAX" "MTU" "${flags_array[@]}"
fi

#check on interface
interface_name=$($CLI_PATH/get/get_nic_config $device_index $port_index DEVICE)
if [ "$interface_name" = "" ]; then
    echo ""
    echo "Please, choose a valid interface."
    echo ""
    exit
fi

#run
$CLI_PATH/set/mtu --device $device_index --port $port_index --value $mtu_value