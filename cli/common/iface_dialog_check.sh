#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g interface_found="0"
declare -g interface_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -i " ]] || [[ " ${flags[$i]} " =~ " --interface " ]]; then # flags[i] is -d or --device
        interface_found="1"
        value_idx=$(($i+1))
        interface_name=${flags[$value_idx]}
    fi  
done

#return the values
echo "$interface_found"
#echo "$value_idx"
echo "$interface_name"