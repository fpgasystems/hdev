#!/bin/bash

#early exit
if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
    exit
fi

#check on server
#virtualized_check "$CLI_PATH" "$hostname"
fpga_check "$CLI_PATH" "$hostname"

#check on software  
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"

#check on flags
valid_flags="-d --device -r --remote -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#initialize
device_found="0"
device_index=""

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    remote_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
if [ "$multiple_devices" = "0" ]; then
    device_found="1"
    device_index="1"
    #check on device_type
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if [ "$device_type" = "asoc" ]; then
        #get current_uuid
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
        product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
        current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
        if [ "$current_uuid" = "$AVED_UUID" ]; then
            exit
        fi
    elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [[ $workflow = "vitis" ]]; then
            exit
        fi
    fi
    echo ""
    echo "${bold}$CLI_NAME $command $arguments${normal}"
    echo ""
elif [ "$device_found" = "0" ]; then   
    echo ""
    echo "${bold}$CLI_NAME $command $arguments${normal}"    
    echo ""
    device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    #check on device_type
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if [ "$device_type" = "asoc" ]; then
        #get current_uuid
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
        product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
        current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
        if [ "$current_uuid" = "$AVED_UUID" ]; then
            exit
        fi
    elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [[ $workflow = "vitis" ]]; then
            exit
        fi
    fi
elif [ "$device_found" = "1" ]; then   
    #check on device_type
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if [ "$device_type" = "asoc" ]; then
        #get current_uuid
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
        product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
        current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
        if [ "$current_uuid" = "$AVED_UUID" ]; then
            exit
        fi
    elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [[ $workflow = "vitis" ]]; then
            exit
        fi
    fi
    echo ""
    echo "${bold}$CLI_NAME $command $arguments${normal}"    
    echo ""
fi

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#run
$CLI_PATH/program/revert --device $device_index --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"