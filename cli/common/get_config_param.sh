#!/bin/bash

#inputs
CLI_PATH=$1
CONFIG_FILE_PATH=$2
parameter_name=$3

parameter_value=$(grep "$parameter_name" $CONFIG_FILE_PATH | awk -F'=' '{print $2}' | tr -d ' ;')

echo $parameter_value