#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g cfile_found="0"
declare -g cfile_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -s " ]] || [[ " ${flags[$i]} " =~ " --source " ]]; then # flags[i] is -d or --device
        cfile_found="1"
        cfile_index_idx=$(($i+1))
        cfile_name=${flags[$cfile_index_idx]}
    fi  
done

#return the values
echo "$cfile_found"
echo "$cfile_name"