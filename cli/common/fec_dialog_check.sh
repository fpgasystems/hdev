#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g fec_option_found="0"
declare -g fec_option=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -f " ]] || [[ " ${flags[$i]} " =~ " --fec " ]]; then # flags[i] is -d or --device
        fec_option_found="1"
        fec_idx=$(($i+1))
        fec_option=${flags[$fec_idx]}
    fi  
done

#return the values
echo "$fec_option_found"
echo "$fec_option"