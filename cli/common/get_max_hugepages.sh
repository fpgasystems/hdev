
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#usage: get_max_hugepages "2M"

size_id=$1

#get page size in kB
if [ "$size_id" = "2M" ]; then
    page_kB="2048"
    page_id="2048kB"
elif [ "$size_id" = "1G" ]; then
    page_kB="1048576"
    page_id="1048576kB"
else
    exit
fi

#total ram on the server (kB)
total_ram_kB=$(grep MemTotal /proc/meminfo | awk '{print $2}')

#get number of NUMA nodes
numa_nodes=$(lscpu | grep "NUMA node(s):" | awk '{print $3}')

#get total ram per NUMA node
total_ram_kB=$(( total_ram_kB / numa_nodes ))

#the maximum amount for pagination is 75% of the total ram
ram_75_kB=$(echo "$total_ram_kB * 0.75" | bc)

#get number of pages
max_pages=$(echo "($ram_75_kB + $page_kB / 2) / $page_kB" | bc)

echo $max_pages