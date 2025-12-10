#!/bin/bash

#early exit
if [ "$is_build" = "1" ]; then
    echo "ERROR: Can't run this command on build servers"
    exit 1
fi
if [ "$vivado_enabled" = "0" ]; then
    echo "ERROR: Vivado has not been found in the PATH"
    exit 1
fi

#check on server
#virtualized_check "$CLI_PATH" "$hostname"
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software  
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"

#check on flags
#NOTE 1:  -v --version are not exposed and not shown in help command or completion
#NOTE 2:  -p --path replace -b --bitstream (which are kept for compatibility)
valid_flags="-b --bitstream -d --device --hotplug -p --path -r --remote -v --version --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    #program_vivado_help
    echo ""
    echo "Your targeted bitstream and device are missing."
    echo ""
    exit 1
else #if [ ! "$flags_array" = "" ]; then      
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    remote_check "$CLI_PATH" "${flags_array[@]}"
    #bitstream_dialog_check
    result="$("$CLI_PATH/common/bitstream_dialog_check" "${flags_array[@]}")"
    bitstream_found=$(echo "$result" | sed -n '1p')
    bitstream_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations (1/2)
    if [ "$bitstream_found" = "0" ] || \
      ( [ "$bitstream_found" = "1" ] && \
        ( [ "$bitstream_name" = "" ] || [ ! -f "$bitstream_name" ] || \
          ( [ "${bitstream_name##*.}" != "bit" ] && [ "${bitstream_name##*.}" != "pdi" ] ) \
        ) \
      )
    then
        echo ""
        echo "Please, choose a valid bitstream name."
        echo ""
        exit 1
    fi
    #forbidden combinations (2/2)
    if [ "$multiple_devices" = "1" ] && [ "$bitstream_found" = "1" ] && [ "$device_found" = "0" ]; then # this means bitstream always needs --device when multiple_devices
        echo ""
        echo $CHECK_ON_DEVICE_ERR_MSG
        echo ""
        exit 1
    fi
    #device values when there is only a device
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    fi

    #check if hotplug flag is present (an empty value is controlled)
    word_check "$CLI_PATH" "--hotplug" "--hotplug" "${flags_array[@]}"
    hotplug_found=$word_found
    hotplug_value=$word_value

    #check on hotplug value
    if [ "$hotplug_found" = "0" ]; then
    #enabled by default
    hotplug_value="1"
    elif [ "$hotplug_found" = "1" ]; then
        if [ "$hotplug_value" != "0" ] && [ "$hotplug_value" != "1" ]; then
            echo ""
            echo $CHECK_ON_HOTPLUG_ERR_MSG
            echo ""
            exit 1
        fi
    fi
fi
echo ""

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$bitstream_name" == "./"* ]]; then
    echo $CHECK_ON_REMOTE_FILE_ERR_MSG
    echo ""
    exit 1
fi

#run
$CLI_PATH/program/bitstream --path $bitstream_name --device $device_index --version $vivado_version --hotplug $hotplug_value --remote $deploy_option "${servers_family_list[@]}"
