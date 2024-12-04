#!/bin/bash

word_1=$1
word_2=$2
shift 2
flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g word_found="0"
declare -g word_value=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " $word_1 " ]] || [[ " ${flags[$i]} " =~ " $word_2 " ]]; then
        word_found="1"
        commit_idx=$(($i+1))
        word_value=${flags[$commit_idx]}
    fi
done

#return the values
echo "$word_found"
echo "$word_value"