#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run socketperf --interface $interface_name --server   $server_ip --size $size_value
#example: /opt/hdev/cli/hdev run socketperf --interface        enp196s0 --server 10.253.74.10 --size          64

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
size_value=$6

#all inputs must be provided
if [ "$interface_name" = "" ] || [ "$server_ip" = "" ] || [ "$size_value" = "" ]; then
    exit
fi

#constants
COLOR_FAILED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FAILED)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
COLOR_PASSED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_PASSED)
#size="64" # bytes
#mps="max"
duration="10" # seconds
corrupt="1"

#get local IP from interface
local_ip=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

# Run sockperf and capture output
echo ""
echo "${bold}Running sockperf latency test:${normal}"
echo ""
command="sockperf ping-pong --tcp -i $server_ip --client_ip $local_ip --msg-size $size_value --mps=max --time $duration --data-integrity"
echo "$command"

output_latency=$(eval "$command" 2>&1)

#check if server is down
if echo "$output_latency" | grep -q "Is the server down?"; then
  echo ""
  echo $output_latency
  echo ""
  echo -e "${COLOR_FAILED}${bold}sockperf test FAILED!${normal}${COLOR_OFF}"
  echo ""
  exit 1
fi

#extract values
latency=$(echo "$output_latency" | grep -oP 'Latency is \K[0-9.]+ usec' | head -n1)

#correctness check (dropped or corrupt messages)
dropped=$(echo "$output_latency" | grep -oP '# dropped messages = \K[0-9]+' | head -n1)
duplicated=$(echo "$output_latency" | grep -oP '# duplicated messages = \K[0-9]+' | head -n1)
corrupt=$((dropped + duplicated))

echo ""
echo "${bold}Running sockperf throughput test:${normal}"
echo ""
command="sockperf throughput --tcp -i $server_ip --client_ip $local_ip --msg-size $size_value --mps=max --time $duration" #data-integrity is not working here
echo "$command"

output_bw=$(eval "$command" 2>&1)

#check if server is down
if echo "$output_bw" | grep -q "Is the server down?"; then
  echo ""
  echo $output_bw
  echo ""
  echo -e "${COLOR_FAILED}${bold}sockperf test FAILED!${normal}${COLOR_OFF}"
  echo ""
  exit 1
fi

#extract values
bandwidth=$(echo "$output_bw" | grep -oP 'BandWidth is \K[0-9.]+ MBps \([0-9.]+ Mbps\)' | head -n1)

#print results
if [ ! "$latency" = "" ] && [ ! "$bandwidth" = "" ]; then
  echo ""
  echo "${bold}Message size (bytes):${normal} $size_value"
  echo "${bold}Latency:${normal} $latency"
  echo "${bold}Bandwith:${normal} $bandwidth"
  if [[ "$corrupt" -eq 0 ]]; then
    echo -e "${bold}Correctness:${normal} ${COLOR_PASSED}${bold}PASSED${normal}${COLOR_OFF}"
  else
    echo -e "${bold}Correctness:${normal} ${COLOR_FAILED}${bold}FAILED (Dropped: $dropped, Duplicated: $duplicated)${normal}${COLOR_OFF}"
  fi
  echo ""
else
  echo ""
  echo "${bold}Message size (bytes):${normal} $size_value"
  echo -e "${COLOR_FAILED}${bold}sockperf test FAILED!${normal}${COLOR_OFF}"
  echo ""
fi

#author: https://github.com/jmoya82