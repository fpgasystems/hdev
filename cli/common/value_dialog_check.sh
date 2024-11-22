#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g value_found="0"
declare -g value=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -v " ]] || [[ " ${flags[$i]} " =~ " --value " ]]; then # flags[i] is -d or --device
        value_found="1"
        value_idx=$(($i+1))
        value=${flags[$value_idx]}
    fi  
done

#return the values
echo "$value_found"
#echo "$value_idx"
echo "$value"