#!/bin/bash

interface_name=$1

if [ -z "$interface_name" ]; then
    echo "Usage: $0 <interface_name>"
    exit 1
fi

sudo ip link set dev "$interface_name" xdp off

#Loop for countdown
countdown=$((RANDOM % 6 + 10))
for i in $(seq $countdown -1 0); do
    echo -n "."
    sleep 0.5
done