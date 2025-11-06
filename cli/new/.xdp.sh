#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$nic_enabled" = "0" ]; then
    exit 1
fi

#check on software
gh_check "$CLI_PATH"

#check on flags
valid_flags="-c --commit --project --push -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check_on_commits
commit_found_bpftool=""
commit_name_bpftool=""
commit_found_libbpf=""
commit_name_libbpf=""
if [ "$flags_array" = "" ]; then
    #commit dialog
    commit_found_bpftool="1"
    commit_found_libbpf="1"
    commit_name_bpftool=$XDP_BPFTOOL_COMMIT
    commit_name_libbpf=$XDP_LIBBPF_COMMIT
    #checks (command line)
    #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')

    #check if commit_name is empty
    if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "xdp" "0" "0" "$is_build" "0" "0" $is_nic "0" "0" $is_network_developer
        exit
    fi
    
    #check if commit_name contains exactly one comma
    if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
        echo ""
        echo "Please, choose valid bpftool and libbpf commit IDs."
        echo ""
        exit
    fi
    
    #get shell and driver commits (shell_commit,driver_commit)
    commit_name_bpftool=${commit_name%%,*}
    commit_name_libbpf=${commit_name#*,}

    #check if commits exist
    exists_bpftool=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $XDP_BPFTOOL_REPO $commit_name_bpftool)
    exists_libbpf=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $XDP_LIBBPF_REPO $commit_name_libbpf)

    if [ "$commit_found" = "0" ]; then 
        commit_name_bpftool=$XDP_BPFTOOL_COMMIT
        commit_name_libbpf=$XDP_LIBBPF_COMMIT
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_bpftool" = "" ] || [ "$commit_name_libbpf" = "" ]); then 
        #$CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
        $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
        exit
    elif [ "$commit_found" = "1" ] && ([ "$exists_bpftool" = "0" ] || [ "$exists_libbpf" = "0" ]); then 
        if [ "$exists_bpftool" = "0" ]; then
            echo ""
            echo "Please, choose a valid bpftool commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
            echo ""
            exit 1
        fi
        if [ "$exists_libbpf" = "0" ]; then
            echo ""
            echo "Please, choose a valid libbpf commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
            echo ""
            exit 1
        fi
    fi
fi

#checks (command line)
if [ ! "$flags_array" = "" ]; then
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"
    push_check "$CLI_PATH" "${flags_array[@]}"
fi

#dialogs
echo ""
echo "${bold}$CLI_NAME $command $arguments (commit IDs for bpftool and libbpf: $commit_name_bpftool,$commit_name_libbpf)${normal}"
echo ""
new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"
push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"

#run
$CLI_PATH/new/xdp --commit $commit_name_bpftool $commit_name_libbpf --project $new_name --push $push_option