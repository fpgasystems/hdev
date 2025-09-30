#!/bin/bash

#early exit
if [[ "$is_build" = "0" && ( "$vivado_enabled" = "0" || "$is_fpga" = "0" ) ]]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -n --name --project --push --hls --help" #-d --device
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check_on_commits
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

    #check if commit_name is empty
    if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
        exit
    fi
    
    #check if commit_name contains exactly one comma
    if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
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
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
        exit
    elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
        if [ "$exists_shell" = "0" ]; then
            echo ""
            echo "Please, choose a valid shell commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
            echo ""
            exit 1
        fi
        if [ "$exists_driver" = "0" ]; then
            echo ""
            echo "Please, choose a valid driver commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
            echo ""
            exit 1
        fi
    fi
fi

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
    #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    list_check "$CLI_PATH" "$CLI_PATH/constants/ONIC_DEVICE_NAMES" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
    hls_check "$CLI_PATH" "${flags_array[@]}"
    push_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit IDs for shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
echo ""
new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
#device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
if [ "$is_build" = "1" ]; then
    list_dialog "$CLI_PATH" "none" "$CLI_PATH/constants/ONIC_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
else
    list_dialog "$CLI_PATH" "$CLI_PATH/devices_acap_fpga" "$CLI_PATH/constants/ONIC_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
fi
hls_dialog "$CLI_PATH" "${flags_array[@]}"
push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"

#collect list results
device_found=$item_found
device_name=$item_name

#check on compatible device
if ! grep -Fxq "$device_name" "$ONIC_DEVICE_NAMES"; then
    echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
    echo ""
    exit 1
fi

#run
$CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $new_name --name $device_name --push $push_option --hls $hls_option