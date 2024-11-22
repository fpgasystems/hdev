#!/bin/bash

flags=("$@")  # Assign command-line arguments to the 'flags' array

# Declare global variables
declare -g driver_found="0"
declare -g driver_name=""

#read flags
for (( i=0; i<${#flags[@]}; i++ ))
do
    if [[ " ${flags[$i]} " =~ " -i " ]] || [[ " ${flags[$i]} " =~ " --insert " ]] || [[ " ${flags[$i]} " =~ " -r " ]] || [[ " ${flags[$i]} " =~ " --remove " ]]; then # flags[i] is -d or --device #|| [[ " ${flags[$i]} " =~ " --driver " ]]
        driver_found="1"
        driver_idx=$(($i+1))
        driver_name=${flags[$driver_idx]}
    fi  
done

#return the values
echo "$driver_found"
echo "$driver_name"