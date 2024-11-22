#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g partition_found="0"
declare -g partition_index=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -p " ]] || [[ " ${flags[$i]} " =~ " --partition " ]]; then # flags[i] is -d or --device
        partition_found="1"
        device_idx=$(($i+1))
        partition_index=${flags[$device_idx]}
    fi  
done

#return the values
echo "$partition_found"
echo "$partition_index"