#!/bin/bash

echo "Yep!"

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
gh_check "$CLI_PATH"
ami_check "$AMI_TOOL_PATH"

#check on flags
#if [ "$is_hdev_developer" = "1" ]; then
    valid_flags="-d --device -n --number --tag --target -h --help"
#else
#  valid_flags="-d --device --tag --target -h --help"
#fi
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on driver (on the contrary to OpenNIC, the driver must be present--at system level--before programming)
if ! lsmod | grep -q ${AVED_DRIVER_NAME%.ko}; then
    echo ""
    echo "Your targeted driver ($AVED_DRIVER_NAME) is missing."
    echo ""
    exit
fi

#check on commit
word_check "$CLI_PATH" "--tag" "--tag" "${flags_array[@]}"
tag_found=$word_found
#commit_name=$word_value

#check on PR
pullrq_found="0"
pullrq_id="none"
if [ "$is_hdev_developer" = "1" ]; then
    word_check "$CLI_PATH" "-n" "--number" "${flags_array[@]}"
    pullrq_found=$word_found
    pullrq_id=$word_value
fi

#tag or PR
if [ "$tag_found" = "1" ] && [ "$pullrq_found" = "1" ]; then
    exit 1
fi

#checks (command line)
#pullrq_found="0"
#pullrq_id="none"
exists_pr="0"
if [ ! "$flags_array" = "" ]; then
    #check on PR
    if [ "$is_hdev_developer" = "1" ]; then
    #word_check "$CLI_PATH" "-n" "--number" "${flags_array[@]}"
    #pullrq_found=$word_found
    #pullrq_id=$word_value

    #check on pullrq_id
    if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
        #echo ""
        #echo $CHECK_ON_PR_ERR_MSG
        #echo ""
        validate_vrt_help
        exit 1
    elif [ "$pullrq_found" == "1" ]; then
        pullrq_id=$word_value
    fi

    #check if PR exist
    exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $VRT_REPO $pullrq_id)
    if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
        echo ""
        echo $CHECK_ON_PR_ERR_MSG
        $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$VRT_REPO"
        exit 1
    fi
    fi

    #either pullrq_id or tag_name
    if [ "$exists_pr" = "1" ]; then
    tag_found="1"
    tag_name=$VRT_TAG
    else
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
    fi
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
    #project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    #remote_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
target_dialog "$CLI_PATH" "VRT_TARGETS" "none" "$is_build" "${flags_array[@]}"

remove_project="1"
if [ ! "$pullrq_id" = "none" ]; then
    remove_project="0"
fi

#run
$CLI_PATH/validate/vrt --device $device_index --tag $tag_name --target $target_name  --version $vivado_version --number $pullrq_id --remove $remove_project