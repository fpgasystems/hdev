#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi


#check on software
gh_check "$CLI_PATH"
#tf_check "$CLI_PATH"

#check on flags
valid_flags="--project --push -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$HIP_TAG" "${flags_array[@]}"
    push_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $HIP_TAG)${normal}"
echo ""
new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$HIP_TAG" "${flags_array[@]}"
push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$HIP_TAG" "${flags_array[@]}"

#run
$CLI_PATH/new/hip --commit $HIP_TAG --project $new_name --push $push_option