#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g config_found="0"
declare -g config_id=""
declare -g config_name="" #examples: --config 0, -c 1

#constants
CONFIG_PREFIX="host_config_"

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -c " ]] || [[ " ${flags[$i]} " =~ " --config " ]]; then
        config_found="1"
        project_idx=$(($i+1))
        config_id=${flags[$project_idx]}
    fi
done

#get config_name
if [ -n "$config_id" ]; then
    config_name=$CONFIG_PREFIX$(printf "%03d" "$config_id")
fi

#return the values
echo "$config_found"
echo "$config_id"
echo "$config_name"