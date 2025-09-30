#!/bin/bash

#early exit
#if [[ "$is_build" = "0" && ( "$vivado_enabled" = "0" || "$is_fpga" = "0" ) ]]; then
if [[ "$is_build" = "1" ||  "$vivado_enabled" = "0" || "$is_fpga" = "0"  ]]; then
    exit
fi

#check on server
#virtualized_check "$CLI_PATH" "$hostname"
fpga_check "$CLI_PATH" "$hostname"

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit -d --device -f --fec -p --project -r --remote -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#initialize
fec_option_found="0"
fec_option=""

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
    device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    fec_check "$CLI_PATH" "${flags_array[@]}"
    remote_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "ONIC_SHELL_COMMIT"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"

#get devices from sh.cfg (device_dialog comes at the end)
device_indexes=()
if [ "$device_found" = "1" ]; then 
    device_indexes=("$device_index")
elif [[ ( "$device_found" = "" || "$device_found" = "0" ) && -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]]; then #elif [ "$device_found" = "" ] && [ -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]; then
    while IFS=":" read -r index name; do
        if [[ ${name// /} == "onic" ]]; then
            device_indexes+=("$index")
        fi
    done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")

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
    if [[ "$(cat "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")" == "[workflows]" ]]; then
        if [[ -n "$device_index" ]]; then
            echo "$device_index: onic" >> "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg"
        fi
    fi
fi

#fec_dialog
if ! (lsmod | grep -q "${ONIC_DRIVER_NAME%.ko}" 2>/dev/null); then
    if [ "$fec_option_found" = "0" ]; then
        echo "${bold}Please, choose your encoding scheme:${normal}"
        echo ""
        echo "0) RS_FEC_ENABLED = 0"
        echo "1) RS_FEC_ENABLED = 1"
        while true; do
            read -p "" choice
            case $choice in
                "0")
                    fec_option="0"
                    break
                    ;;
                "1")
                    fec_option="1"
                    break
                    ;;
            esac
        done
        echo ""
    fi
else
    #when the driver is inserted fec_option is irrelevant
    fec_option="-" 
fi

#bitstream check (this should never happen as hdev new opennic is for a specific device_name)
for i in "${!device_indexes[@]}"; do
    FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH "${device_indexes[$i]}") #$device_index
    bitstream_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
    if ! [ -e "$bitstream_path" ]; then
        echo "Your targeted bitstream ($FDEV_NAME) is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
        echo ""
        exit 1
    fi
done

#driver check
driver_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/$ONIC_DRIVER_NAME"
if ! [ -e "$driver_path" ]; then
    echo "Your targeted driver is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
    echo ""
    exit 1
fi

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#run
for i in "${!device_indexes[@]}"; do
    $CLI_PATH/program/opennic --commit $commit_name --device ${device_indexes[$i]} --fec $fec_option --project $project_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}" 
done