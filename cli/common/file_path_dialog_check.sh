#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g file_path_found="0"
declare -g file_path=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -p " ]] || [[ " ${flags[$i]} " =~ " --path " ]]; then # flags[i] is -d or --device
        file_path_found="1"
        idx=$(($i+1))
        file_path=${flags[$idx]}
    fi  
done

#return the values
echo "$file_path_found"
echo "$file_path"