#!/bin/bash

#username=$1
#workflow=$2

MY_PROJECT_PATH=$1

# Declare global variables
declare -g config_found="0"
declare -g config_name=""
declare -g multiple_configs="0"
declare -g num_configs
declare -g config_index=""

# Enable nullglob to make unmatched globs expand to nothing
shopt -s nullglob

#get configs
cd "$MY_PROJECT_PATH/configs/"
configs=( *config_* )

#remove selected files
configs_aux=()
for element in "${configs[@]}"; do
    if [[ ($element != "config_000" && $element != "host_config_000") && $element != *.hpp ]]; then
        configs_aux+=("$element")
    fi
done

#number of configs
num_configs=${#configs_aux[@]}

# Check if there is only one directory
if [ $num_configs -eq 0 ]; then #${#configs_aux[@]}
    config_name=""
elif [ $num_configs -eq 1 ]; then #${#configs_aux[@]}
    config_found="1"
    config_name=${configs_aux[0]}
else
    multiple_configs="1"
    PS3=""
    select config_name in "${configs_aux[@]}"; do
        if [[ -z $config_name ]]; then
            echo "" >&/dev/null
        else
            config_found="1"
            # Extract the last part of the string after the last underscore
            config_index="${config_name##*_}"

            # Remove leading zeros
            config_index=$((10#$config_index))
            break
        fi
    done
fi

# Return the values of config_found and config_name
echo "$config_found"
echo "$config_name"
echo "$multiple_configs"
echo "$num_configs"
echo "$config_index"