#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new tensorflow --commit $TENSORFLOW_COMMIT --project   $new_name --push $push_option
#example: /opt/hdev/cli/hdev new tensorflow --commit            b9ba6f2 --project hello_world --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "0" ]; then
    exit 1
fi

#inputs
TENSORFLOW_COMMIT=$2
new_name=$4
push_option=$6

#all inputs must be provided
if [ "$TENSORFLOW_COMMIT" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

echo "Inside!"

#author: https://github.com/jmoya82