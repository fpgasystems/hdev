#!/bin/bash

device_type=$1
DEVICES_LIST=$2

MAX_DEVICES=$(grep -E $device_type $DEVICES_LIST | wc -l)

echo "$MAX_DEVICES"