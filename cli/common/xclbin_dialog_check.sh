#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g xclbin_found="0"
declare -g xclbin_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -x " ]] || [[ " ${flags[$i]} " =~ " --xclbin " ]]; then # flags[i] is -p or --xclbin
        xclbin_found="1"
        xclbin_idx=$(($i+1))
        xclbin_name=${flags[$xclbin_idx]}
    fi
done

#return the values
echo "$xclbin_found"
echo "$xclbin_name"