#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev set balancing --value $new_value
#example: /opt/hdev/cli/hdev set balancing --value          1

#early exit
is_numa=$($CLI_PATH/common/is_numa $CLI_PATH)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_numa" = "0" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#inputs
new_value=$2

#all inputs must be provided
if [ "$new_value" = "" ]; then
    exit
fi

#get current value
current_value=$(cat /proc/sys/kernel/numa_balancing)

# Compare current and new
if [ "$current_value" = "$new_value" ]; then
    # Nothing to do
    exit
fi

echo ""
echo "sudo sysctl kernel.numa_balancing=$new_value"
echo ""
sudo sysctl kernel.numa_balancing=$new_value >/dev/null 2>&1
sleep 2