#!/bin/bash

#inputs
CLI_PATH=$1
hostname=$2

#constants
BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"

#check for build
build="0"
if (grep -q "^$hostname$" $BUILD_SERVERS_LIST); then
    build="1"
fi

#output
echo $build