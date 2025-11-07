#!/bin/bash

#early exit
if { [[ "$is_acap" = "0" && "$is_fpga" = "0" ]]; } || [[ "$is_asoc" = "1" ]]; then
    exit
fi

#check on server
#virtualized_check "$CLI_PATH" "$hostname"
fpga_check "$CLI_PATH" "$hostname"

#check on software  
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"

#check on flags
valid_flags="-d --device -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
    if [ ! "$workflow" = "vitis" ]; then
        echo ""
        echo $CHECK_ON_REVERT_ERR_MSG
        echo ""
        exit
    fi
fi

xrt_check "$CLI_PATH"
echo ""

#dialogs
echo "${bold}$CLI_NAME $command $arguments${normal}"
echo ""
device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
if [ ! "$workflow" = "vitis" ]; then
    echo $CHECK_ON_REVERT_ERR_MSG
    echo ""
    exit
fi
xrt_shell_check "$CLI_PATH" "$device_index"

#run
$CLI_PATH/program/reset --device $device_index