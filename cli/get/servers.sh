#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST $CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#get servers
#echo ""
#echo "${bold}Quering remote servers with ssh:${normal}"
result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
num_remote_servers=$(echo "$servers_family_list" | wc -w)

#check on number of servers
if [ "$num_remote_servers" -eq 0 ]; then
    echo ""
    echo "Please, verify that you can ssh the targeted remote servers."
    echo ""
    exit
fi

#convert servers_family_list to an array
IFS=' ' read -ra servers_family_list_array <<< "$servers_family_list"

#print
if [ ${#servers_family_list_array[@]} -gt 0 ]; then
    server_index=1
    echo ""
    for server in "${servers_family_list_array[@]}"; do
        echo "$server_index: $server"
        ((server_index++))
    done
    echo ""
fi