#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g template_found="0"
declare -g template_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -t " ]] || [[ " ${flags[$i]} " =~ " --template " ]]; then
        template_found="1"
        template_idx=$(($i+1))
        template_name=${flags[$template_idx]}
    fi
done

#return the values
echo "$template_found"
echo "$template_name"