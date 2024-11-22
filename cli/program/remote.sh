#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH=$1
username=$2
deploy_option=$3
programming_string=$4
shift 4
servers_family_list="$@"

if [ "$deploy_option" -eq 1 ] && [ -n "$servers_family_list" ]; then 
    echo "${bold}Programming remote servers:${normal}"
    #echo ""
    #convert string to array
    IFS=" " read -ra servers_family_list_array <<< "$servers_family_list"
    for i in "${servers_family_list_array[@]}"; do
        echo ""
        echo "${bold}$i...${normal}"
        echo ""
        ssh -t $username@$i "$programming_string"
    done
    echo ""
fi