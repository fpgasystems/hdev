#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev program xdp --commit $commit_name --interface $interface_name --project $project_name --start $function_name
#example: /opt/hdev/cli/hdev program xdp --commit      8077751 --interface    enp35s0f0np0 --project   hello_world --start   pass_drop

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
function_name=$8

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$interface_name" = "" ] || [ "$project_name" = "" ] || [ "$function_name" = "" ]; then
    exit
fi

#constants
COLOR_FAILED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FAILED)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
COLOR_PASSED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_PASSED)
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

#function_name="pass_drop"

# Define a temporary file in the specified directory
temp_output="$DIR/temp_output"
touch "$temp_output"

#program application
echo "${bold}Attaching your XDP/eBPF function:${normal}"
echo ""
echo "sudo ./$function_name $interface_name &>/dev/null &"
echo ""
sudo ./$function_name $interface_name >"$temp_output" 2>&1 &

# Get the PID of the background process
pid=$!

#Loop for countdown
countdown=$((RANDOM % 6 + 10))
for i in $(seq $countdown -1 0); do
    echo -n "."
    sleep 0.5
done

echo ""

# Check if the word "FATAL" is present in the output
if cat "$temp_output" | grep -q "FATAL"; then
    return_code=1
    #echo "An error occurred while attaching the XDP program."
    echo ""
    echo -e "${COLOR_FAILED}Error while attaching ${bold}$function_name!${normal}${COLOR_FAILED}${COLOR_OFF}"
    echo ""
else
    return_code=0
    #echo "XDP program attached successfully."
    echo ""
    echo -e "${COLOR_PASSED}${bold}$function_name (pid $pid)${normal} ${COLOR_PASSED}successfully attached!${COLOR_OFF}"
    echo ""
fi

# Clean up the temporary file
rm -f "$temp_output"

#exit with return code
exit $return_code

#author: https://github.com/jmoya82