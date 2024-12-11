#!/bin/sh

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

#get BDF
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%?}1"

#split
bus=${bdf:0:2}
device=${bdf:3:2}
function=${bdf:6:1}

#core commands
#eval "sudo echo 100 > /sys/bus/pci/devices/0000\:$bus\:$device.$function/qdma/qmax"
echo "echo 100 > /sys/bus/pci/devices/0000\:$bus\:$device.$function/qdma/qmax"
echo "dma-ctl qdma$bus$device$function q add idx 0 mode mm dir bi"
sleep 1
echo "dma-ctl qdma$bus$device$function q start idx 0 idx_ringsz 15 dir bi"
sleep 1
echo "chmod 666 /dev/qdma$bus$device$function-MM-0"