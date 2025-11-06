#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#check on server
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"
ami_check "$AMI_TOOL_PATH"

#check on flags
valid_flags="-d --device -p --project -t --tag -r --remote -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on driver (on the contrary to OpenNIC, the driver must be present--at system level--before programming)
if ! lsmod | grep -q ${AVED_DRIVER_NAME%.ko}; then
    echo ""
    echo "Your targeted driver ($AVED_DRIVER_NAME) is missing."
    echo ""
    exit
fi

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    remote_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
#device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

#get devices from sh.cfg (device_dialog comes at the end)
device_indexes=()
if [ "$device_found" = "1" ]; then 
    device_indexes=("$device_index")
elif [[ ( "$device_found" = "" || "$device_found" = "0" ) && -f "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg" ]]; then 
    while IFS=":" read -r index name; do
        if [[ ${name// /} == "vrt" ]]; then
            device_indexes+=("$index")
        fi
    done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg")

    #there is at least one onic device
    if [[ ${#device_indexes[@]} -gt 0 ]]; then
        device_found="1"
    fi
fi

#final check
if [ "$device_found" = "" ] || [ "$device_found" = "0" ]; then
    device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    device_indexes=("$device_index")

    #add to sh.cfg
    if [[ "$(cat "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg")" == "[workflows]" ]]; then
        if [[ -n "$device_index" ]]; then
            echo "$device_index: vrt" >> "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg"
        fi
    fi
fi

#check on template
VRT_TEMPLATE=$(cat $MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/VRT_TEMPLATE)

#vrtbin check
vrtbin_path="$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/hw_all.$VRT_TEMPLATE.$vivado_version/${VRT_TEMPLATE}_hw.vrtbin"
if ! [ -e "$vrtbin_path" ]; then
    echo "Your targeted VRT binary is missing. Please, use ${bold}$CLI_NAME build $arguments${normal} for ${bold}hw_all.${normal}"
    echo ""
    exit 1
fi

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#run
for i in "${!device_indexes[@]}"; do
    #$CLI_PATH/program/vrt --device $device_index --project $project_name --tag $tag_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
    $CLI_PATH/program/vrt --device ${device_indexes[$i]} --project $project_name --tag $tag_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
done