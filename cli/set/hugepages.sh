#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev set hugepages --size $size_id --number $number_value
#example: /opt/hdev/cli/hdev set hugepages --size       1G --number            32

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#inputs
size_id=$2
number_value=$4

#all inputs must be provided
if [ "$size_id" = "" ] || [ "$number_value" = "" ]; then
    exit
fi

#get page size in kB
if [ "$size_id" = "2M" ]; then
    page_kB="2048"
    page_id="2048kB"
elif [ "$size_id" = "1G" ]; then
    page_kB="1048576"
    page_id="1048576kB"
fi

#total ram on the server (kB)
total_ram_kB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
echo "total_ram_kB: $total_ram_kB"

#the maximum amount for pagination is 75% of the total ram
ram_75_kB=$(echo "$total_ram_kB * 0.75" | bc)
echo "ram_75_kB: $ram_75_kB"

#get number of pages
max_pages=$(echo "($ram_75_kB + $page_kB / 2) / $page_kB" | bc)
echo "max_pages: $max_pages"

#verify the number of pages is valid
if [ "$number_value" -gt "$max_pages" ]; then
    exit
fi

echo "I am here!"

cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages

sudo sh -c "echo 6 > /sys/kernel/mm/hugepages/hugepages-$page_id/nr_hugepages"

cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages

#get interface_name

    #set mtu_value
#    sudo ifconfig $interface_name hugepages $mtu_value up > /dev/null 2>&1
