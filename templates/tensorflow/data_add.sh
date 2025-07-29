#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CONFIG_IDX="$1"

if [ "$CONFIG_IDX" = "" ] && [ -f "./configs/host_config_000" ]; then
    ./config_add
    CONFIG_IDX="1"
    #config_string="001"
    
    #cleanup data
    rm -rf ./data/input_000
    rm -f ./data/output.npy
else
    # Check for correct number of arguments
    if [ "$#" -ne 1 ]; then
        echo ""
        echo "Usage: $0 host_config_idx"
        echo ""
        exit 1
    fi
    add_echo="1"
fi

get_config_string() {
  local num="$1"
  printf "%0${MAX_STR_LENGTH}d" "$num"
}

#inputs
#CONFIG_IDX="$1"

#constants
MAX_STR_LENGTH=3

#get configuration string
config_string=$(get_config_string "$CONFIG_IDX")

#ensure running config_add
#if [ -f "./configs/host_config_000" ]; then
#    ./config_add
#    config_string="001"
    
#    #cleanup data
#    rm -rf ./data/input_000
#    rm -f ./data/output.npy
#fi

#check on host_config
if [ ! -f "./configs/host_config_$config_string" ]; then
    echo ""
    echo "Host configuration not found!"
    echo ""
    exit 1
fi

#get the number of inputs to generate
#num_input_signals=$(grep -o "\.npy" kn.cfg | wc -l)

#read kernel names into an array
kernels=($(grep -E '^[0-9]+:' kn.cfg | cut -d: -f2- | sed 's/^[ \t]*//'))

# Loop through each kernel
num_input_signals=0
for kernel in "${kernels[@]}"; do
    count=$(grep -E "^sp=${kernel}\.in[0-9]+:.*\.npy" "${kernel}.cfg" | wc -l)
    ((num_input_signals += count))
done

#get data_type (precision) from device_config
data_type=$(awk -F '=' '/^precision/ {gsub(/ /, "", $2); gsub(/;/, "", $2); print $2}' ./configs/device_config)

#get size from a host configuration
size=$(grep '^N' ./configs/host_config_$config_string | cut -d'=' -f2 | tr -d ' ;')

if [ ! -d "./data/input_$config_string" ]; then
    #create directory
    mkdir -p ./data/input_$config_string
    cd ./data/input_$config_string

    #write device_parameters
    #while IFS='=;' read -r key value _; do
    #    key=$(echo "$key" | xargs)     # Trim whitespace
    #    value=$(echo "$value" | xargs) # Trim whitespace
    #    [ -n "$key" ] && echo "$value" > "$key"
    #done < ../../configs/device_config
    cp ../../configs/device_config .

    #write device_parameters
    cp ../../configs/host_config_$config_string .

    #run Python
    if [ "$add_echo" = "1" ]; then
        echo ""
    fi
    echo "${bold}Creating data:${normal}"
    echo ""
    echo "python3 ../../src/data_add.py $num_input_signals $data_type $size"
    echo ""
    python3 ../../src/data_add.py $num_input_signals $data_type $size
    
    sleep 2
    echo "Done!"
    echo ""
fi