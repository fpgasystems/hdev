#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="--name --number --tag --template --project --push -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on tag
word_check "$CLI_PATH" "--tag" "--tag" "${flags_array[@]}"
tag_found=$word_found
tag_name=$word_value

#check on PR
pullrq_found="0"
pullrq_id="none"
if [ "$is_hdev_developer" = "1" ]; then
    word_check "$CLI_PATH" "--number" "--number" "${flags_array[@]}"
    pullrq_found=$word_found
    pullrq_id=$word_value
fi

#tag or PR
if [ "$tag_found" = "1" ] && [ "$pullrq_found" = "1" ]; then
    exit 1
fi

#check_on_tag
#tag_found=""
#tag_name=""
if [ "$flags_array" = "" ]; then
    #tag dialog
    tag_found="1"
    tag_name=$VRT_TAG
    pullrq_found="0"
    pullrq_id="none"
    #header
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
    echo ""
elif [ "$tag_found" = "1" ]; then
    #set pullrq_id
    pullrq_found="0"
    pullrq_id="none"

    #check if tag_name is empty
    if [ "$tag_found" = "1" ] && [ "$tag_name" = "" ]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "vrt" "0" $is_asoc $is_build "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
        exit 1
    fi

    #check if tag exist
    exists_tag=$($CLI_PATH/common/gh_tag_check $GITHUB_CLI_PATH $VRT_REPO $tag_name)
    if [ "$tag_found" = "1" ] && [ "$exists_tag" = "0" ]; then 
        echo ""
        echo $CHECK_ON_GH_TAG_ERR_MSG
        echo ""
        exit 1
    fi

    #header
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
    echo ""
elif [ "$pullrq_found" = "1" ]; then
    #set tag
    tag_found="0"
    tag_name="none"

    #check on pullrq_id
    if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "vrt" "0" $is_asoc $is_build "0" "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
        exit 1
    #elif [ "$pullrq_found" == "1" ]; then
    #    pullrq_id=$word_value
    fi

    #check if PR exist
    exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $VRT_REPO $pullrq_id)
    if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
        echo ""
        echo $CHECK_ON_PR_ERR_MSG
        $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$VRT_REPO"
        exit 1
    fi
    #header
    echo ""
    echo "${bold}$CLI_NAME $command $arguments (pull request ID: #$pullrq_id)${normal}"
    echo ""
fi

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
    #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    list_check "$CLI_PATH" "$CLI_PATH/constants/VRT_DEVICE_NAMES" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
    template_check "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
    push_check "$CLI_PATH" "${flags_array[@]}"
    #template_check "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
fi

#dialogs
#echo ""
#echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
#echo ""
new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
#device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
list_dialog "$CLI_PATH" "$CLI_PATH/constants/VRT_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
template_dialog  "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"

#collect list results
device_found=$item_found
device_name=$item_name

#get device_name
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#check on compatible device
if ! grep -Fxq "$device_name" "$VRT_DEVICE_NAMES"; then
    echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
    echo ""
    exit 1
fi

echo "tag_name: $tag_name"
echo "new_name: $new_name"
echo "device_name: $device_name"
echo "template_name: $template_name"
echo "push_option: $push_option"
echo "pullrq_id: $pullrq_id"
exit

#run
$CLI_PATH/new/vrt --tag $tag_name --project $new_name --name $device_name --template $template_name --push $push_option --number $pullrq_id