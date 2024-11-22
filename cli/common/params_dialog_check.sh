#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g params_found="0"
declare -g params_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -p " ]] || [[ " ${flags[$i]} " =~ " --params " ]]; then # flags[i] is -d or --device
        params_found="1"
        params_idx=$(($i+1))
        params_name=${flags[$params_idx]}
    fi  
done

#return the values
echo "$params_found"
echo "$params_name"