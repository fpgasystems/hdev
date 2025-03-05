#!/bin/bash

#inputs
CLI_PATH=$1

num_numa_nodes=$(lscpu | grep "NUMA node(s):" | awk '{print $NF}')

is_numa=0
if [ "$num_numa_nodes" -ge 2 ]; then
    is_numa=1
fi

#output
echo $is_numa