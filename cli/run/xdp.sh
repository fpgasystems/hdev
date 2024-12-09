#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run xdp --commit $commit_name --interface $interface_name --project $project_name
#example: /opt/hdev/cli/hdev run xdp --commit      8077751 --interface    enp35s0f0np0 --project   hello_world

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
    exit 1
fi

#inputs
commit_name=$2
interface_name=$4
project_name=$6

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$interface_name" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="xdp"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#echo "HEY I am here: $interface_name"
#echo "sudo ./pass_drop $interface_name &>/dev/null &"
#exit

#run application
echo "${bold}Running your XDP/eBPF function:${normal}"
echo ""
echo "sudo ./pass_drop $interface_name &>/dev/null &"
echo ""
sudo ./pass_drop $interface_name &>/dev/null &
pid=$!  # Capture the PID of the background process

# Wait for the process to finish and capture the return code
#wait $pid
#return_code=$?

sleep 2

echo "El PID es $pid"

# Check if the program ran successfully
#if [[ $return_code -eq 0 ]]; then
#    echo "Program inserted successfully (PID $pid)."
#else
#    echo "Error occurred. Exit code: $return_code"
#fi

echo ""

#exit with return code
exit $return_code

#author: https://github.com/jmoya82