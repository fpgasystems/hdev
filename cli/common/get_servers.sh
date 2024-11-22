#!/bin/bash

CLI_PATH=$1
SERVER_LIST=$2
hostname=$3
username=$4

test_ssh_access() {
    local username="$1"
    local server="$2"
    /usr/bin/ssh -q -o BatchMode=yes -o ConnectTimeout=5 "$username@$server" exit
    return $?  # Return the SSH exit status
}

# Declare global variables
declare -g servers_family_list=""
declare -g servers_family_list_string=""

# Convert string to an array
SERVER_LIST=($SERVER_LIST)

# Loop through the server list and test SSH access
servers=()
for server in "${SERVER_LIST[@]}"; do
    # Use timeout command to limit the test_ssh_access function execution time
    timeout 10s bash -c "$(declare -f test_ssh_access); test_ssh_access '$username' '$server'"
    if [ $? -eq 0 ]; then
        servers+=("$server")
    fi
done

# We only show likely servers (i.e., alveo-u55c)
server_family="${hostname%???}"

# Build servers_family_list
servers_family_list=()
for server in "${servers[@]}"; do
    if [[ $server == $server_family* ]] && [[ $server != $hostname ]]; then
        # Append the matching element to the array
        servers_family_list+=("$server") 
    fi
done

# Convert to string and remove the leading delimiter
servers_family_list_string=$(printf ", %s" "${servers_family_list[@]}")
servers_family_list_string=${servers_family_list_string:2}
  
# Return the array
echo "${servers_family_list[@]}"
echo "${servers_family_list_string[@]}"