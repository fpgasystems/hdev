#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#create workflow directory
mkdir -p "$MY_PROJECTS_PATH/$arguments"

#temporal exit condition
if [ "$is_asoc" = "1" ]; then
    echo ""
    echo "Sorry, we are working on this!"
    echo ""
    exit
fi

#check on server
#virtualized_check "$CLI_PATH" "$hostname"
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -d --device -f --fec -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line 1/2 - check_on_commits)
commit_found_shell=""
commit_name_shell=""
commit_found_driver=""
commit_name_driver=""
if [ "$flags_array" = "" ]; then
    #commit dialog
    commit_found_shell="1"
    commit_found_driver="1"
    commit_name_shell=$ONIC_SHELL_COMMIT
    commit_name_driver=$ONIC_DRIVER_COMMIT
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')

    #check if commit_name contains exactly one comma
    if [ "$commit_found" = "1" ] && { [ "$commit_name" = "" ] || ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; }; then #if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
        echo ""
        echo "Please, choose valid shell and driver commit IDs."
        echo ""
        exit
    fi
    
    #get shell and driver commits (shell_commit,driver_commit)
    commit_name_shell=${commit_name%%,*}
    commit_name_driver=${commit_name#*,}

    #check if commits exist
    exists_shell=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_SHELL_REPO $commit_name_shell)
    exists_driver=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_DRIVER_REPO $commit_name_driver)

    if [ "$commit_found" = "0" ]; then 
        commit_name_shell=$ONIC_SHELL_COMMIT
        commit_name_driver=$ONIC_DRIVER_COMMIT
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$exists_shell" = "0" ]); then
        echo ""
        echo "Please, choose a valid shell commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
        echo ""
        exit 1
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_driver" = "" ] || [ "$exists_driver" = "0" ]); then
        echo ""
        echo "Please, choose a valid driver commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
        echo ""
        exit 1
    fi
fi
#echo ""

#initialize
device_found="0"
device_index=""
fec_option_found="0"
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
    bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name_shell/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
    if ! [ -e "$bitstream_path" ]; then
        echo ""
        echo "$CHECK_ON_BITSTREAM_ERR_MSG"
        echo ""
        exit 1
    fi
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
else
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
fi

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#check on compatible device
if ! grep -Fxq "$device_name" "$ONIC_DEVICE_NAMES"; then
    echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
    echo ""
    exit 1
fi

#bitstream check (the bitstream must be pre-compiled for validation)
#FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)
bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name_shell/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if ! [ -e "$bitstream_path" ]; then
    echo "$CHECK_ON_BITSTREAM_ERR_MSG"
    echo ""
    exit 1
fi

#dialogs
if [ "$fec_option_found" = "0" ]; then
    echo "${bold}Please, choose your encoding scheme:${normal}"
    echo ""
    echo "0) RS_FEC_ENABLED = 0"
    echo "1) RS_FEC_ENABLED = 1"
    while true; do
        read -p "" choice
        case $choice in
            "0")
                fec_option="0"
                break
                ;;
            "1")
                fec_option="1"
                break
                ;;
        esac
    done
    echo ""
fi

#run
$CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --fec $fec_option --version $vivado_version