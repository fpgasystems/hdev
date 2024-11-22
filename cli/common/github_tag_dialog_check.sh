#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g commit_found="0"
declare -g commit_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -t " ]] || [[ " ${flags[$i]} " =~ " --tag " ]]; then
        commit_found="1"
        commit_idx=$(($i+1))
        commit_name=${flags[$commit_idx]}
    fi
done

#return the values
echo "$commit_found"
echo "$commit_name"