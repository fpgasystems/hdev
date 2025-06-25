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
size=64 # bytes
mps=100
duration=10 # seconds

# Get local IP from interface
local_ip=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

# Run sockperf and capture output
command="sockperf ping-pong --tcp -i $server_ip --client_ip $local_ip --msg-size $size --mps $mps --time $duration --data-integrity"
echo "$command"

output=$(eval "$command" 2>&1)
echo "$output"

# Extract values
latency=$(echo "$output" | grep -oP 'avg-latency=\K[0-9.]+' | head -n1)
sent=$(echo "$output" | grep -oP 'SentMessages=\K[0-9]+' | head -n1)
received=$(echo "$output" | grep -oP 'ReceivedMessages=\K[0-9]+' | head -n1)

# Throughput in MBps: (received messages * msg size) / duration / 1024 / 1024
throughput_mb=$(awk -v r="$received" -v s="$size" -v d="$duration" 'BEGIN { printf "%.4f", (r * s) / d / 1024 / 1024 }')

# Correctness check (dropped or corrupt messages)
dropped=$(echo "$output" | grep -oP '# dropped messages = \K[0-9]+' | head -n1)
duplicated=$(echo "$output" | grep -oP '# duplicated messages = \K[0-9]+' | head -n1)
corrupt=$((dropped + duplicated))

# Print results
echo "Latency(us): $latency"
echo "Throughput: ${throughput_mb} MB/s"

if [[ "$corrupt" -eq 0 ]]; then
  echo "Correctness: PASS"
else
  echo "Correctness: FAIL"
  echo "Dropped: $dropped, Duplicated: $duplicated"
fi

#author: https://github.com/jmoya82