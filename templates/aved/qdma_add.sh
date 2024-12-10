#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

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

echo "HEY $bdf"




#author: https://github.com/jmoya82