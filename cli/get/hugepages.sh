#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
    exit
fi

#get values
two_MG=$(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)
one_GB=$(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)

echo ""
echo "/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages   : $two_MG"
echo "/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages: $one_GB"
echo ""