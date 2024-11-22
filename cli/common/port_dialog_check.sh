#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g port_found="0"
declare -g port_index=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -p " ]] || [[ " ${flags[$i]} " =~ " --port " ]]; then # flags[i] is -d or --device
        port_found="1"
        port_idx=$(($i+1))
        port_index=${flags[$port_idx]}
    fi  
done

#return the values
echo "$port_found"
echo "$port_index"