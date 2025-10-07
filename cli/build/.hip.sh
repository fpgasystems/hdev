#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#check on software
gh_check "$CLI_PATH"

#constants
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)

#verify hip workflow (based on installed software)
test1=$(dkms status | grep amdgpu)
if [ -z "$test1" ] || [ ! -d "$ROCM_PATH/bin/" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check on flags
valid_flags="-p --project -t --tag -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks on command line
if [ ! "$flags_array" = "" ]; then
    word_check "$CLI_PATH" "-t" "--tag" "${flags_array[@]}"
    tag_found=$word_found
    tag_name=$word_value
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
fi

#dialogs
#check on tag
if [ "$tag_found" = "0" ]; then
    tag_found="1"
    tag_name=$(cat $HDEV_PATH/TAG)
fi
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"

#run
$CLI_PATH/build/hip --tag $tag_name --project $project_name
echo ""