#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#only one parameter is allowed
if [ "$#" -ne 1 ]; then
    exit 1
fi

#inputs
device_index=$1

#check on device index
MAX_NUM_DEVICES=$(cat $CLI_PATH/devices_acap_fpga | wc -l)
if [ "$device_index" -lt 1 ] || [ "$device_index" -gt "$MAX_NUM_DEVICES" ]; then
    echo ""
    echo "Please, choose a valid device index."
    echo ""
    exit 1
fi

#constants
MAX_PROMPT_ELEMENTS=10
INC_STEPS=2
INC_DECIMALS=2

#derived
BUILD_DIRECTORY="$MY_PROJECT_PATH/dma_ip_drivers/QDMA/linux-kernel/driver"

#save original pci_ids.h
cp $BUILD_DIRECTORY/src/pci_ids.h $BUILD_DIRECTORY/src/pci_ids.h.backup

#get PCIe identifier
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%?}1"
pci_id=$(lspci | grep Xilinx | grep $bdf | awk '{print $NF}')

echo "HEY $pci_id"

#author: https://github.com/jmoya82