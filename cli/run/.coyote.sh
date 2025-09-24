#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#check on server
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="--commit --config -p --project -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#constants
CONFIG_PREFIX="host_config_"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    if [ "$project_found" = "1" ]; then
        config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "yes" "${flags_array[@]}"
    fi
fi

if [ "$project_found" = "0" ]; then
    add_echo="no"
fi

#dialogs
commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$COYOTE_REPO" "$COYOTE_COMMIT" "${flags_array[@]}"
commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "COYOTE_COMMIT"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
config_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "$add_echo" "${flags_array[@]}"
if [ "$project_found" = "1" ] && [ ! -e "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/$config_name" ]; then
    echo ""
    echo "$CHECK_ON_CONFIG_ERR_MSG"
    echo ""
    exit
fi
#device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

#get coyote devices from sh.cfg (similar to hdev program coyote)
if [ -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]; then
    while IFS=":" read -r index name; do
        if [[ ${name// /} == "coyote" ]]; then
            device_indexes+=("$index")
        fi
    done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")
else
    #echo ""
    echo $CHECK_ON_SHELL_CFG_ERR_MSG
    echo ""
    exit 1
fi

#coyote workflow check
for i in "${!device_indexes[@]}"; do
    device_index_i="${device_indexes[$i]}"
    workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index_i)
    if [ ! "$workflow" = "coyote" ]; then
        echo "$CHECK_ON_WORKFLOW_ERR_MSG"
        echo ""
        exit
    fi
done

echo "HEY I am here"
exit

#coyote application check
if [ ! -x "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/coyote" ]; then
    echo "Your targeted application is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
    echo ""
    exit 1
fi

#run
$CLI_PATH/run/coyote --commit $commit_name --config $config_index --project $project_name 