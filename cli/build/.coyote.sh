#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
vitis_hls_version=$($CLI_PATH/common/get_xilinx_version vitis)
vitis_hls_check "$VITIS_HLS_PATH" "$vitis_hls_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -p --project -t --target -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#set default target
target_found="0"
target_name=""

#checks on command line
if [ ! "$flags_array" = "" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    target_check "$CLI_PATH" "COYOTE_TARGETS" "${flags_array[@]}"
    if [ "$is_build" = "0" ] && [ "$target_name" = "hw" ]; then
        echo ""
        echo "$CHECK_ON_TARGET_ERR_MSG"
        echo ""
        exit 1
    fi
fi

#dialogs
commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "COYOTE_COMMIT"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
#target_dialog "$CLI_PATH" "COYOTE_TARGETS" "hw" "$is_build" "${flags_array[@]}"

#set project_shell
device_name=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/COYOTE_DEVICE_NAME)
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)
project_shell="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#check on target_name
if [ "$is_build" = "1" ] && [ ! -e "$project_shell" ]; then
    target_found="1"
    target_name="hw"
elif [ "$target_found" = "0" ]; then
    #target_name="none"
    target_dialog "$CLI_PATH" "COYOTE_TARGETS" "hw" "$is_build" "${flags_array[@]}"
fi

#echo "device_name: $device_name"
#echo "FDEV_NAME: $FDEV_NAME"
#echo "project_shell: $project_shell"
#echo "target_name: $target_name"
#exit

#get template_name
template_name=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/COYOTE_TEMPLATE)

#we force the user to create a configuration
if [ "$template_name" = "none" ] && [ ! -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/device_config" ]; then
    #get current path
    current_path=$(pwd)
    cd "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name"
    echo "${bold}Adding device and host configurations with ./config_add:${normal}"
    ./config_add
    cd "$current_path"
fi

#echo "commit_name: $commit_name"
#echo "project_name: $project_name"
#echo "target_found: $target_found"
#echo "target_name: $target_name"
#echo "vivado_version: $vivado_version"
#echo "is_build: $is_build"
#exit

#run
$CLI_PATH/build/coyote --commit $commit_name --project $project_name --target $target_name --version $vivado_version --is_build $is_build
echo ""