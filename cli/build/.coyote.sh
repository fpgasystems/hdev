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
valid_flags="-c --commit -p --project -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks on command line
if [ ! "$flags_array" = "" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    target_check "$CLI_PATH" "COYOTE_TARGETS" "${flags_array[@]}"
fi

#additional forbidden combination
if [ "$is_build" = "0" ] && [ "$platform_found" = "1" ]; then
    build_opennic_help
fi

#dialogs
commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "COYOTE_COMMIT"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
target_dialog "$CLI_PATH" "COYOTE_TARGETS" "hw_emu" "$is_build" "${flags_array[@]}"

#we force the user to create a configuration
if [ ! -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/device_config" ]; then
    #get current path
    current_path=$(pwd)
    cd "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name"
    echo "${bold}Adding device and host configurations with ./config_add:${normal}"
    ./config_add
    cd "$current_path"
fi

#run
$CLI_PATH/build/coyote --commit $commit_name --project $project_name --version $vivado_version --all $is_build #--platform $device_name
echo ""