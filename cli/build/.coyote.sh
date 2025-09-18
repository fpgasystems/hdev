#!/bin/bash

echo "Hey I am here"
exit

#early exit
if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit --name --project --push --number --help -t --template" #-d --device
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on commit
commit_name=$COYOTE_COMMIT
word_check "$CLI_PATH" "-c" "--commit" "${flags_array[@]}"
commit_found=$word_found
if [ "$commit_found" = "1" ]; then
    commit_name=$word_value
fi

#check on PR
pullrq_found="0"
pullrq_id="none"
if [ "$is_hdev_developer" = "1" ]; then
    word_check "$CLI_PATH" "--number" "--number" "${flags_array[@]}"
    pullrq_found=$word_found
    if [ "$pullrq_found" = "1" ]; then
        pullrq_id=$word_value
    fi
fi

#commit or PR
if [ "$commit_found" = "1" ] && [ "$pullrq_found" = "1" ]; then
    exit 1
fi

#header string
header_string="(commit ID: $commit_name)"

#check_on_commits
if [ "$flags_array" = "" ]; then
    #commit dialog
    commit_found="1"
    commit_name=$COYOTE_COMMIT
    pullrq_found="0"
    pullrq_id="none"
elif [ "$commit_found" = "1" ]; then
    #set pullrq_id
    pullrq_found="0"
    pullrq_id="none"

    #check if commit_name is empty
    if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "coyote" $is_acap $is_asoc $is_build $is_fpga "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
        exit 1
    fi

    #check if commits exist
    exists_commit=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $COYOTE_REPO $commit_name)
    if [ "$commit_found" = "1" ] && [ "$exists_commit" = "0" ]; then 
        echo ""
        echo $CHECK_ON_COMMIT_ERR_MSG
        echo ""
        exit 1
    fi
elif [ "$pullrq_found" = "1" ]; then
    #set commit
    commit_found="0"
    commit_name="$COYOTE_COMMIT"

    #check on pullrq_id
    if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "coyote" $is_acap $is_asoc $is_build $is_fpga "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
        exit 1
    fi

    #check if PR exist
    exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $COYOTE_REPO $pullrq_id)
    if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
        echo ""
        echo $CHECK_ON_PR_ERR_MSG
        $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$COYOTE_REPO"
        exit 1
    fi

    #header string
    header_string="(pull request ID: #$pullrq_id)"
fi

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    list_check "$CLI_PATH" "$CLI_PATH/constants/COYOTE_DEVICE_NAMES" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
    template_check "$CLI_PATH" "COYOTE_TEMPLATES" "${flags_array[@]}"
    push_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
echo ""
echo "${bold}$CLI_NAME $command $arguments $header_string${normal}"
echo ""
new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
list_dialog "$CLI_PATH" "$CLI_PATH/devices_acap_fpga" "$CLI_PATH/constants/COYOTE_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
template_dialog  "$CLI_PATH" "COYOTE_TEMPLATES" "${flags_array[@]}"
push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"

#collect list results
device_found=$item_found
device_name=$item_name

#check on compatible device
if ! grep -Fxq "$device_name" "$COYOTE_DEVICE_NAMES"; then
    echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
    echo ""
    exit 1
fi

#run
$CLI_PATH/new/coyote --commit $commit_name --number $pullrq_id --project $new_name --name $device_name --template $template_name --push $push_option