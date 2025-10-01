#!/bin/bash

CLI_PATH=$1
TARGET_FILE=$2
TARGET_DEPLOY_EXCLUDE=$3
is_build=$4

# Declare global variables
declare -g target_name=""
#declare -a targets

#check on deploy server
if [ "$is_build" = "0" ]; then 
    is_deploy="1"
fi

# Read file into array
mapfile -t all_targets < "$CLI_PATH/constants/$TARGET_FILE"

#exclude TARGET_DEPLOY_EXCLUDE
if [ "$is_deploy" = "1" ]; then 
    filtered_targets=()
    for target in "${all_targets[@]}"; do
        if [[ "$target" != "$TARGET_DEPLOY_EXCLUDE" ]]; then
            filtered_targets+=("$target")
        fi
    done
else
    filtered_targets=("${all_targets[@]}")
fi

if [[ ${#filtered_targets[@]} -eq 1 ]]; then
    target_name=${filtered_targets[0]}
    #echo "You selected: $target_name"
else
    PS3=""
    select target_name in "${filtered_targets[@]}"; do
        if [[ -n "$target_name" ]]; then
            echo "$target_name"
            break
        fi
    done
fi

echo "$target_name"