#!/bin/bash

function_name=$1
interface_name=$2

#if [ -z "$function_name" ] || [ -z "$interface_name" ]; then
#    echo "Usage: $0 <function_name> <interface_name>"
#    exit 1
#fi

sudo ./$function_name $interface_name &