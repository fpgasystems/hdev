#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new opennic --commit $commit_name_shell $commit_name_driver --project   $new_name --device $device_index --push $push_option
#example: /opt/hdev/cli/hdev new opennic --commit             807775             1cf2578 --project hello_world --device             1 --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
#if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#temporal exit condition
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
if [ "$is_asoc" = "1" ]; then
    echo ""
    echo "Sorry, we are working on this!"
    echo ""
    exit
fi

check_connectivity() {
    local interface="$1"
    local remote_server="$2"

    # Ping the remote server using the specified interface, sending only 1 packet
    if ping -I "$interface" -c 1 "$remote_server" &> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

#inputs
commit_name_shell=$2
commit_name_driver=$3
new_name=$5
device_index=$7
push_option=$9

#all inputs must be provided
if [ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ] || [ "$new_name" = "" ] || [ "$device_index" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
ACAP_SERVERS_LIST="$CLI_PATH/constants/ACAP_SERVERS_LIST"
BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"
CMDB_PATH="$CLI_PATH/cmdb"
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"
DEVICES_LIST_NETWORKING="$CLI_PATH/devices_network"
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
GPU_SERVERS_LIST="$CLI_PATH/constants/GPU_SERVERS_LIST"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NETWORKING_DEVICE_INDEX="1"
NETWORKING_PORT_INDEX="1"
#ONIC_DEVICE_NAMES="$CLI_PATH/constants/ONIC_DEVICE_NAMES"
WORKFLOW="opennic"

#get devices number
if [ -s "$DEVICES_LIST_NETWORKING" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NETWORKING"
fi

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_opennic $DIR $commit_name_shell $commit_name_driver

#change to project directory
#cd $DIR

#save commit_name_shell
echo "$commit_name_shell" > $DIR/ONIC_SHELL_COMMIT
echo "$commit_name_driver" > $DIR/ONIC_DRIVER_COMMIT

#add template files
#mkdir -p $DIR/src
cp $HDEV_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $HDEV_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $HDEV_PATH/templates/$WORKFLOW/Makefile $DIR/Makefile
cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp -r $HDEV_PATH/templates/$WORKFLOW/src $DIR
cp $HDEV_PATH/templates/$WORKFLOW/sh.cfg $DIR/sh.cfg

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete

#get interface name
interface_name=$($CLI_PATH/get/get_nic_config $NETWORKING_DEVICE_INDEX $NETWORKING_PORT_INDEX DEVICE)

#read SERVERS_LISTS excluding the current hostname
IFS=$'\n' read -r -d '' -a remote_servers < <(cat "$ACAP_SERVERS_LIST" "$BUILD_SERVERS_LIST" "$FPGA_SERVERS_LIST" "$GPU_SERVERS_LIST" | grep -v "^$hostname$" | sort -u && printf '\0')

#get target host
target_host=""
connected=""
for server in "${remote_servers[@]}"; do
    # Check connectivity to the current server
    if [[ "$(check_connectivity "$interface_name" "$server")" == "1" ]]; then
        target_host="$server"
        break
    fi
done

#get NIC IP for remote server
for dir in "$CMDB_PATH"/"$target_host"*; do
  if [[ -d "$dir" ]]; then
    full_name="$(basename "$dir")"
    break
  fi
done
target_host_ip=$($CLI_PATH/get/get_nic_device_param 1 IP $CLI_PATH/cmdb/$full_name/devices_network)
first_ip="${target_host_ip%%/*}"

#update remote_server in config_parameters
sed -i "/^remote_server/s/xxxx-xxxxx-xx/$first_ip/" "$DIR/config_parameters"

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#save to 
echo "$device_name" > $DIR/ONIC_DEVICE_NAME

#add to sh.cfg (get index of the first FPGA)
#index=$(awk -v devname="$device_name" '$6 == devname { print $1; exit }' "$DEVICES_LIST_FPGA")
#if [[ -n "$index" ]]; then
    echo "$device_index: onic" >> "$DIR/sh.cfg"
#fi


# Iterate over each ONIC device name



#SH_CFG="$DIR/sh.cfg"
## Loop through all ONIC device names
#while IFS= read -r device_name || [[ -n "$device_name" ]]; do
#    echo ">>> Checking: '$device_name'" >&2  # debug
#
#    # Check exact match on $6
#    awk -v dev="$device_name" '$6 == dev { print $1 ": onic" }' "$DEVICES_LIST_FPGA"
#done < "$ONIC_DEVICE_NAMES" >> "$SH_CFG"

#push files
if [ "$push_option" = "1" ]; then 
    cd $DIR
    #update README.md 
    if [ -e README.md ]; then
        rm README.md
    fi
    echo "# "$new_name >> README.md
    #add gitignore
    echo ".DS_Store" >> .gitignore
    #add, commit, push
    git add .
    git commit -m "First commit"
    git push --set-upstream origin master
    echo ""
fi

#print message
echo "The project ${bold}$DIR${normal} has been created!"
echo ""

#author: https://github.com/jmoya82