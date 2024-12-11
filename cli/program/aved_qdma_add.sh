#!/bin/sh

#only one parameter is allowed
if [ "$#" -ne 1 ]; then
    exit 1
fi

#inputs
bdf=$1

#split
bus=$(echo "$bdf" | cut -d':' -f1)
device=$(echo "$bdf" | cut -d'.' -f1 | cut -d':' -f2)
function=$(echo "$bdf" | cut -d'.' -f2)

#core commands
echo "echo 100 > /sys/bus/pci/devices/0000\:$bus\:$device.$function/qdma/qmax"
echo 100 > /sys/bus/pci/devices/0000\:$bus\:$device.$function/qdma/qmax
sleep 1
echo ""

echo "dma-ctl qdma$bus$device$function q add idx 0 mode mm dir bi"
dma-ctl qdma$bus$device$function q add idx 0 mode mm dir bi
sleep 1
echo ""

echo "dma-ctl qdma$bus$device$function q start idx 0 idx_ringsz 15 dir bi"
dma-ctl qdma$bus$device$function q start idx 0 idx_ringsz 15 dir bi
sleep 1
echo ""

echo "chmod 666 /dev/qdma$bus$device$function-MM-0"
chmod 666 /dev/qdma$bus$device$function-MM-0
sleep 1
echo ""