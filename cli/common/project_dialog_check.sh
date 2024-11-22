#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g project_found="0"
#declare -g project_idx=""
declare -g project_path=""
declare -g project_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -p " ]] || [[ " ${flags[$i]} " =~ " --project " ]]; then # flags[i] is -p or --project
        project_found="1"
        project_idx=$(($i+1))
        project_path=${flags[$project_idx]}
    fi
done

# Remove trailing '/' characters
project_name="${project_path%%/}"

# Remove everything before the last '/' character
project_name="${project_name##*/}"

#return the values
echo "$project_found"
echo "$project_path"
echo "$project_name"