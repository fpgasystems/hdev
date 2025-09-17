#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new coyote --commit $commit_name --number $pullrq_id --project   $new_name --name  $device_name --push $push_option
#example: /opt/hdev/cli/hdev new coyote --commit       807775 --number        137 --project hello_world --name xcu280_u55c_0 --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#temporal exit condition
url="${HOSTNAME}"
hostname="${url%%.*}"

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
commit_name=$2
pullrq_id=$4
new_name=$6
device_name=$8
push_option=${10}

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$pullrq_id" = "" ] || [ "$new_name" = "" ] || [ "$device_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

echo "Hey I am here"
exit

#constants
#ACAP_SERVERS_LIST="$CLI_PATH/constants/ACAP_SERVERS_LIST"
#BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"
#CMDB_PATH="$CLI_PATH/cmdb"
#DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"
#DEVICES_LIST_NETWORKING="$CLI_PATH/devices_network"
#FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
#GPU_SERVERS_LIST="$CLI_PATH/constants/GPU_SERVERS_LIST"
#MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#NETWORKING_DEVICE_INDEX="1"
#NETWORKING_PORT_INDEX="1"
#ONIC_DEVICE_NAMES="$CLI_PATH/constants/ONIC_DEVICE_NAMES"
WORKFLOW="coyote"

#get devices number
if [ -s "$DEVICES_LIST_NETWORKING" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NETWORKING"
fi

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
#$CLI_PATH/common/git_clone_opennic $DIR $commit_name $commit_name_driver

#change to project directory
#cd $DIR

#save commit_name
echo "$commit_name" > $DIR/ONIC_SHELL_COMMIT

#get device_name
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#save ONIC_DEVICE_NAME 
echo "$device_name" > $DIR/ONIC_DEVICE_NAME

#add api files
cp $HDEV_PATH/api/config_add $DIR
cp $HDEV_PATH/api/config_delete $DIR

#add template files
#mkdir -p $DIR/src
#cp $HDEV_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
#cp $HDEV_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $HDEV_PATH/templates/$WORKFLOW/Makefile $DIR/Makefile
cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp -r $HDEV_PATH/templates/$WORKFLOW/src $DIR
cp $HDEV_PATH/templates/$WORKFLOW/sh.cfg $DIR/sh.cfg

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete

#device_name to FDEV_NAME
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)

#hls-wrapper
#if [ -f "$HDEV_PATH/templates/$WORKFLOW/$WRAPPER_NAME/p2p_250mhz_hls_$FDEV_NAME.tcl" ]; then
if [ "$hls_option" = "1" ]; then
    #copy plugin
    cp -r $DIR/open-nic-shell/plugin/p2p $DIR/open-nic-shell/plugin/$WRAPPER_NAME
    #250mhz
    cp $HDEV_PATH/templates/$WORKFLOW/$WRAPPER_NAME/p2p_250mhz_hls_$FDEV_NAME.tcl $DIR/open-nic-shell/plugin/$WRAPPER_NAME/box_250mhz
    cp $HDEV_PATH/templates/$WORKFLOW/$WRAPPER_NAME/p2p_250mhz_hls.cpp $DIR/open-nic-shell/plugin/$WRAPPER_NAME/box_250mhz
    #322mhz
    cp $HDEV_PATH/templates/$WORKFLOW/$WRAPPER_NAME/p2p_322mhz_hls_$FDEV_NAME.tcl $DIR/open-nic-shell/plugin/$WRAPPER_NAME/box_322mhz
    cp $HDEV_PATH/templates/$WORKFLOW/$WRAPPER_NAME/p2p_322mhz_hls.cpp $DIR/open-nic-shell/plugin/$WRAPPER_NAME/box_322mhz
fi
rm -rf $DIR/$WRAPPER_NAME

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
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#save to 
#echo "$device_name" > $DIR/ONIC_DEVICE_NAME

#add to sh.cfg (get index of the first FPGA)
device_index=$(awk -v devname="$device_name" '$6 == devname { print $1; exit }' "$DEVICES_LIST_FPGA")
if [[ -n "$device_index" ]]; then
    echo "$device_index: onic" >> "$DIR/sh.cfg"
fi

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