#!/bin/bash

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_gpu"

#examples:
#  $CLI_PATH/get/get_gpu_device_param 1 bus 
#  $CLI_PATH/get/get_gpu_device_param 1 bus $CLI_PATH/cmdb/hacc-box-02.inf.ethz.ch/devices_gpu

#constants (id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC)
ID_COLUMN=1
BUS_COLUMN=2
DEVICE_TYPE_COLUMN=3
GPU_ID_COLUMN=4
SERIAL_NUMBER_COLUMN=5
UNIQUE_ID_COLUMN=6

#inputs (./examine 0 root_port)
device_index=$1
parameter=$2
device_list_path=$3

if [ ! "$device_list_path" = "" ]; then
  DEVICES_LIST=$device_list_path
fi

#helper functions
get_column() {
  parameter=$1
  case "$parameter" in
    # id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC  
    id)
      column=$ID_COLUMN
      ;;
    bus)
      column=$BUS_COLUMN
      ;;
    device_type)
      column=$DEVICE_TYPE_COLUMN
      ;;
    gpu_id)
      column=$GPU_ID_COLUMN
      ;;
    serial_number)
      column=$SERIAL_NUMBER_COLUMN
      ;;
    unique_id)
      column=$UNIQUE_ID_COLUMN
      ;;
    *)
      echo "Unknown parameter $parameter."
      ;;
  esac
  echo $column
}

if [[ -f "$DEVICES_LIST" ]]; then
  #print if the first fpga/acap is valid
  #device_1=$(head -n 1 "$DEVICES_LIST")
  #bus_1=$(echo "$device_1" | awk '{print $2}')
  #if [[ -n "$(lspci | grep $bus_1)" ]]; then
    #get column for the parameter
    parameter_column=$(get_column $parameter)
    #output device parameter
    awk -v device_index="$device_index" -v parameter_column="$parameter_column" '$1 == device_index {print $parameter_column}' $DEVICES_LIST
  #fi
fi