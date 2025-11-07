#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#check on server
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software  
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
ami_check "$AMI_TOOL_PATH"

#check on flags
valid_flags="-d --device --partition --path -r --remote -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    #program_vivado_help
    echo ""
    echo "Your targeted device and image are missing."
    echo ""
    exit
else
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    #device values when there is only a device
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    fi
    partition_check "$CLI_PATH" "$device_index" "${flags_array[@]}"
    remote_check "$CLI_PATH" "${flags_array[@]}"
    #file_path_dialog_check
    result="$("$CLI_PATH/common/file_path_dialog_check" "${flags_array[@]}")"
    file_path_found=$(echo "$result" | sed -n '1p')
    file_path=$(echo "$result" | sed -n '2p')
    #forbidden combinations (1/2)
    if [ "$file_path_found" = "0" ] || ([ "$file_path_found" = "1" ] && ([ "$file_path" = "" ] || [ ! -f "$file_path" ] || [ "${file_path##*.}" != "pdi" ])); then
        echo ""
        echo "Please, choose a valid image path."
        echo ""
        exit
    fi
    #forbidden combinations (2/2)
    if [ "$multiple_devices" = "1" ] && [ "$file_path_found" = "1" ] && [ "$device_found" = "0" ]; then # this means image always needs --device when multiple_devices
        echo ""
        echo $CHECK_ON_DEVICE_ERR_MSG
        echo ""
        exit
    fi
fi
echo ""

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$file_path" == "./"* ]]; then
    echo $CHECK_ON_REMOTE_FILE_ERR_MSG
    echo ""
    exit
fi

#echo "I am here"
#echo "device_index: $device_index"
#echo "path: $file_path"
#echo "remote: $deploy_option"
#echo "partition_index: $partition_index"
#exit

#run
if [ "$partition_index" = "none" ]; then
    $CLI_PATH/program/bitstream --path $file_path --device $device_index --version $vivado_version --hotplug "1" --remote $deploy_option "${servers_family_list[@]}" 
else
    $CLI_PATH/program/image --device $device_index --path $file_path --partition $partition_index --remote $deploy_option "${servers_family_list[@]}"
fi