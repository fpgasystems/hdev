#!/bin/bash

#early exit
if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -d --driver -p --project -h --help" 
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks on command line
if [ ! "$flags_array" = "" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    #word_check "$CLI_PATH" "-d" "--driver" "${flags_array[@]}"
fi

#dialogs
commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "XDP_BPFTOOL_COMMIT"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID for bpftool: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"

#get XDP_LIBBPF_COMMIT from project
commit_name_libbpf=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/XDP_LIBBPF_COMMIT)

#run
$CLI_PATH/build/xdp --commit $commit_name $commit_name_libbpf --project $project_name #--driver $word_value
echo ""