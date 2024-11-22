#!/bin/bash

target_host=$1

# Declare global variables
declare -g target_name=""
declare -a targets

# Set targets
targets=("sw_emu" "hw_emu" "hw")
if [ "$target_host" = "1" ]; then
    targets=("host" "sw_emu" "hw_emu" "hw")
fi

PS3=""
select target_name in "${targets[@]}"
do
    case $target_name in
        host) break;;
        sw_emu) break;;
        hw_emu) break;;
        hw) break;;
    esac
done

echo "$target_name"