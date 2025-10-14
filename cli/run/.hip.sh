#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#check on software
gh_check "$CLI_PATH"

#constants
DEVICES_LIST="$CLI_PATH/devices_gpu"
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#verify hip workflow (based on installed software)
test1=$(dkms status | grep amdgpu)
if [ -z "$test1" ] || [ ! -d "$ROCM_PATH/bin/" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check on flags
valid_flags="-d --device -p --project -t --tag -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "gpu" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#set defaults
tag_found="0"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    word_check "$CLI_PATH" "-t" "--tag" "${flags_array[@]}"
    tag_found=$word_found
    tag_name=$word_value
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
fi

#dialogs
#check on tag
if [ "$tag_found" = "0" ]; then
    tag_found="1"
    tag_name=$(cat $HDEV_PATH/TAG)
fi
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

#hip application check
if [ ! -x "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/hip" ]; then
    echo "Your targeted application is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
    echo ""
    exit 1
fi

#run
$CLI_PATH/run/hip --device $device_index --tag $tag_name --project $project_name 