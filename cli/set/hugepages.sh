#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev set hugepages --size $size_id --pages $pages_value
#example: /opt/hdev/cli/hdev set hugepages --size       1G --pages           32

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
pages_value=$4

#all inputs must be provided
if [ "$size_id" = "" ] || [ "$pages_value" = "" ]; then
    exit
fi

#get page size in kB
if [ "$size_id" = "2M" ]; then
    page_id="2048kB"
elif [ "$size_id" = "1G" ]; then
    page_id="1048576kB"
else
    exit
fi

#get maximum number of pages
max_pages=$($CLI_PATH/common/get_max_hugepages $size_id)

#verify the number of pages is valid
if [ "$pages_value" -gt "$max_pages" ]; then
    exit
fi

#set hugepages
echo "$pages_value" | sudo tee /sys/kernel/mm/hugepages/hugepages-$page_id/nr_hugepages > /dev/null 2>&1