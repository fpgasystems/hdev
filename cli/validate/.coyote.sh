#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#create workflow directory
mkdir -p "$MY_PROJECTS_PATH/$arguments"

#check on server
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -d --device -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#constants
TEMPLATE_NAME="01_hello_world"

#checks (command line 1/2 - check_on_commits)
commit_found=""
commit_name=""
if [ "$flags_array" = "" ]; then
    #commit dialog
    commit_found="1"
    commit_name=$COYOTE_COMMIT
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')

    #check if commit_name contains exactly one comma
    if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
        echo ""
        echo $CHECK_ON_COMMIT_ERR_MSG
        echo ""
        exit
    fi
    
    #check if commits exist
    exists_commit=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $COYOTE_REPO $commit_name)

    if [ "$commit_found" = "0" ]; then 
        commit_name=$COYOTE_COMMIT
    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ] || [ "$exists_commit" = "0" ]); then
        echo ""
        echo $CHECK_ON_COMMIT_ERR_MSG
        echo ""
        exit 1
    fi
fi
#echo ""

#initialize
device_found="0"
device_index=""
fec_option=""

#checks (command line 2/2)
if [ ! "$flags_array" = "" ]; then
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    fec_check "$CLI_PATH" "${flags_array[@]}"
fi

if [ "$multiple_devices" = "0" ]; then
    device_found="1"
    device_index="1"
    #bitstream check (the bitstream must be pre-compiled for validation)
    FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
    bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name/$TEMPLATE_NAME/${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
    if ! [ -e "$bitstream_path" ]; then
        echo ""
        echo "$CHECK_ON_BITSTREAM_ERR_MSG"
        echo ""
        exit 1
    fi
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
    echo ""
else
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
    echo ""
    device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
fi

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#check on compatible device
if ! grep -Fxq "$device_name" "$COYOTE_DEVICE_NAMES"; then
    echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
    echo ""
    exit 1
fi

#bitstream check (the bitstream must be pre-compiled for validation)
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)
bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name/$TEMPLATE_NAME/${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if ! [ -e "$bitstream_path" ]; then
    echo "$CHECK_ON_BITSTREAM_ERR_MSG"
    echo ""
    exit 1
fi

echo "HEYE!"
exit

#run
$CLI_PATH/validate/coyote --commit $commit_name --device $device_index --version $vivado_version