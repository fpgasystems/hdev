#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
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

#set default target
#target_found="0"
#target_name=""

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
    target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
    if [ "$is_build" = "0" ] && [ "$target_name" = "hw_all" ]; then
        echo ""
        echo "$CHECK_ON_TARGET_ERR_MSG"
        echo ""
        exit 1
    fi
fi

#dialogs
tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
#template_dialog  "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
target_dialog "$CLI_PATH" "VRT_TARGETS" "hw_all" "$is_build" "${flags_array[@]}"
#when not specified explicitely, only the application will be compiled
#if [ "$target_found" = "0" ]; then
#    target_name="none"
#fi

#run with all set to one (as compiling with hacc-build servers did not work) 
$CLI_PATH/build/vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version --all 1