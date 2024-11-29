#!/bin/bash

#inputs
CLI_PATH=$1
hostname=$2

#constants
NIC_SERVERS_LIST="$CLI_PATH/constants/NIC_SERVERS_LIST"

#check for asoc
asoc="0"
if (grep -q "^$hostname$" $NIC_SERVERS_LIST); then
    asoc="1"
fi

#output
echo $asoc