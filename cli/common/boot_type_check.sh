#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g boot_type_found="0"
declare -g boot_type=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -t " ]] || [[ " ${flags[$i]} " =~ " --type " ]]; then # flags[i] is -d or --device
        boot_type_found="1"
        device_idx=$(($i+1))
        boot_type=${flags[$device_idx]}
    fi  
done

#return the values
echo "$boot_type_found"
echo "$boot_type"