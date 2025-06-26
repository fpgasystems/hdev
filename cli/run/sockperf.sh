#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run socketperf --interface $interface_name --server   $server_ip 
#example: /opt/hdev/cli/hdev run socketperf --interface        enp196s0 --server 10.253.74.10

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ] && [ "$is_nic" = "0" ]; then
    exit
fi

#inputs
interface_name=$2
server_ip=$4

#all inputs must be provided
if [ "$interface_name" = "" ] || [ "$server_ip" = "" ]; then
    exit
fi

#constants
COLOR_FAILED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FAILED)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
COLOR_PASSED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_PASSED)
size="64" # bytes
mps="max"
duration="10" # seconds

# Get local IP from interface
local_ip=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

# Run sockperf and capture output
echo ""
echo "${bold}Running sockperf latency test:${normal}"
echo ""
command="sockperf ping-pong --tcp -i $server_ip --client_ip $local_ip --msg-size $size --mps $mps --time $duration --data-integrity"
echo "$command"

output=$(eval "$command" 2>&1)
#echo "$output"

#extract values
latency=$(echo "$output" | grep -oP 'Latency is \K[0-9.]+ usec' | head -n1)

#correctness check (dropped or corrupt messages)
dropped=$(echo "$output" | grep -oP '# dropped messages = \K[0-9]+' | head -n1)
duplicated=$(echo "$output" | grep -oP '# duplicated messages = \K[0-9]+' | head -n1)
corrupt=$((dropped + duplicated))

echo ""
echo "${bold}Running sockperf throughput test:${normal}"
echo ""
command="sockperf throughput --tcp -i $server_ip --client_ip $local_ip --msg-size 64 --mps $mps --time $duration" #data-integrity is not working here
echo "$command"

output=$(eval "$command" 2>&1)
#echo "$output"

#extract values
bandwidth=$(echo "$output" | grep -oP 'BandWidth is \K[0-9.]+ MBps \([0-9.]+ Mbps\)' | head -n1)

#print results
echo ""
echo "Latency: $latency"
echo "Bandwith: $bandwidth"
if [[ "$corrupt" -eq 0 ]]; then
  echo -e "Correctness: ${COLOR_PASSED}${bold}PASSED${normal}${COLOR_OFF}"
else
  echo -e "Correctness: ${COLOR_FAILED}${bold}FAILED (Dropped: $dropped, Duplicated: $duplicated)${normal}${COLOR_OFF}"
fi
echo ""

#author: https://github.com/jmoya82