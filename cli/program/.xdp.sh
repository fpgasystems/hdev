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
valid_flags="-c --commit -i --interface -p --project --start --stop -h --help" # -f --function 
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#initialize
interface_found="0"
start_found="0"

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    #check on start/stop
    word_check "$CLI_PATH" "--start" "--start" "${flags_array[@]}"
    start_found=$word_found
    start_name=$word_value
    word_check "$CLI_PATH" "--stop" "--stop" "${flags_array[@]}"
    stop_found=$word_found
    stop_name=$word_value

    if [ "$stop_found" = "1" ] && [ "${#flags_array[@]}" -gt 2 ]; then
    exit
    elif [ "$stop_found" = "1" ]; then
    #echo "We need to take action"
    #check if the provided interface is already (xdp) otherwise error and then stop it by killing the pid

    #get XDP interfaces
    interfaces=($($CLI_PATH/common/get_interfaces $CLI_PATH))
    xdp_interfaces=()
    for i in "${interfaces[@]}"; do
        if ip link show "$i" | grep -q "xdp"; then
        xdp_interfaces+=("$i")
        fi
    done

    #check if the interface is an xdp interface
    if [ ${#xdp_interfaces[@]} -eq 0 ] || ! [[ " ${xdp_interfaces[@]} " =~ " $stop_name " ]]; then
        echo ""
        echo $CHECK_ON_IFACE_ERR_MSG
        echo ""
        exit
    fi

    #kill xdp propgram
    echo ""
    echo "${bold}Detaching XDP/eBPF function:${normal}"
    echo ""
    echo "sudo $CLI_PATH/program/xdp_detach $stop_name"
    echo ""            
    sudo $CLI_PATH/program/xdp_detach $stop_name
    exit
    elif [ "$stop_found" = "0" ]; then
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
    #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
    iface_check "$CLI_PATH" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    #remote_check "$CLI_PATH" "${flags_array[@]}"
    fi
fi

#early interface check (already XDP)
if [ "$interface_found" = "1" ]; then
    if ip link show "$interface_name" | grep -q "xdp"; then
        echo ""
        #echo "$CHECK_ON_IFACE_ERR_MSG"
        echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
        echo ""
        exit
    fi
fi

#early XDP application check (already XDP)
if [ "$project_found" = "1" ]; then
    if [ "$start_found" = "1" ] && ([ "$start_name" = "" ] || [ ! -e "$MY_PROJECTS_PATH/xdp/$commit_name/$project_name/$start_name" ]); then
        echo ""
        echo "Please, choose a valid XDP program."
        echo ""
        exit
    fi
fi

#dialogs
commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
#device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
if [ "$interface_found" = "0" ]; then
    iface_dialog "$CLI_PATH" "$CLI_NAME" "${flags_array[@]}"
fi

#interface check (already XDP)
if ip link show "$interface_name" | grep -q "xdp"; then
    echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
    echo ""
    exit
fi

#XDP programs check
output_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/.output"
if ! [ -e "$output_path" ]; then
    echo "Your targeted XDP programs are missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
    echo ""
    exit 1
fi

#start_name dialog
if [ "$start_found" = "0" ]; then
    #get all eBPF/XDP programs
    folders=($(find "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/src" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))

    # Check if there are any folders
    if [[ ${#folders[@]} -eq 0 ]]; then
        #echo "No folders found in $functions."
        echo ""
        echo "Please, create an XDP/eBPF program first."
        echo ""
        exit 1
    fi

    # Display a menu using select
    PS3=""
    echo "${bold}Please, choose your program:${normal}"
    echo ""
    select folder in "${folders[@]}"; do
        if [[ -n "$folder" ]]; then
            start_name=$folder
            echo ""
            break
        fi
    done
fi

#interface check (already XDP)
#if ip link show "$interface_name" | grep -q "xdp"; then
#  echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
#  echo ""
#  exit
#fi

#XDP application check
if [ "$start_found" = "1" ] && ([ "$start_name" = "" ] || [ ! -e "$MY_PROJECTS_PATH/xdp/$commit_name/$project_name/$start_name" ]); then
    echo ""
    echo "Please, choose a valid XDP program."
    echo ""
    exit
fi

#run
$CLI_PATH/program/xdp --commit $commit_name --interface $interface_name --project $project_name --start $start_name