#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="--tag --target --project -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
    target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
fi

#dialogs
tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
target_dialog "$CLI_PATH" "VRT_TARGETS" "none" "$is_build" "${flags_array[@]}"

#check on target
VRT_TEMPLATE=$(cat $MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/VRT_TEMPLATE)
if [ ! -d "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/$target_name.$VRT_TEMPLATE.$vivado_version" ]; then
    echo $CHECK_ON_TARGET_BUILD_ERR_MSG
    echo ""
    exit
fi

#run
$CLI_PATH/run/vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version