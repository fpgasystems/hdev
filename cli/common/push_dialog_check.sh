#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g push_found="0"
declare -g push_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " --push " ]]; then
        push_found="1"
        push_idx=$(($i+1))
        push_name=${flags[$push_idx]}
    fi
done

#return the values
echo "$push_found"
echo "$push_name"