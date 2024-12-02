#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new xdp --commit $commit_name_bpftool $commit_name_libbpf --project   $new_name --push $push_option
#example: /opt/hdev/cli/hdev new xdp --commit              687e7f0             20c0a9e --project hello_world --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
    exit 1
fi

#inputs
commit_name_bpftool=$2
commit_name_libbpf=$3
new_name=$5
push_option=$7

#all inputs must be provided
if [ "$commit_name_bpftool" = "" ] || [ "$commit_name_libbpf" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
#ACAP_SERVERS_LIST="$CLI_PATH/constants/ACAP_SERVERS_LIST"
#BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"
#DEVICES_LIST_NETWORKING="$CLI_PATH/devices_network"
#FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
#GPU_SERVERS_LIST="$CLI_PATH/constants/GPU_SERVERS_LIST"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#NETWORKING_DEVICE_INDEX="1"
#NETWORKING_PORT_INDEX="1"
WORKFLOW="xdp"

#get devices number
#if [ -s "$DEVICES_LIST_NETWORKING" ]; then
#  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NETWORKING"
#fi

#get hostname
#url="${HOSTNAME}"
#hostname="${url%%.*}"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_bpftool/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name_bpftool

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_xdp $DIR $commit_name_bpftool $commit_name_libbpf

#change to project directory
#cd $DIR

#save commit_name_bpftool
echo "$commit_name_bpftool" > $DIR/XDP_BPFTOOL_COMMIT
echo "$commit_name_libbpf" > $DIR/XDP_LIBBPF_COMMIT

#add template files
#mkdir -p $DIR/src
#cp $HDEV_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
#cp $HDEV_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
#cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $HDEV_PATH/templates/$WORKFLOW/Makefile $DIR/Makefile
#cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp -r $HDEV_PATH/templates/$WORKFLOW/src $DIR
cp $HDEV_PATH/templates/$WORKFLOW/apps.mk $DIR/lib/apps.mk
cp $HDEV_PATH/templates/$WORKFLOW/helpers.bash $DIR/lib/helpers.bash
cp $HDEV_PATH/templates/$WORKFLOW/vars.mk $DIR/lib/vars.mk

#compile files
#chmod +x $DIR/config_add
#chmod +x $DIR/config_delete

#get interface name
#interface_name=$($CLI_PATH/get/get_nic_config $NETWORKING_DEVICE_INDEX $NETWORKING_PORT_INDEX DEVICE)

#read SERVERS_LISTS excluding the current hostname
#IFS=$'\n' read -r -d '' -a remote_servers < <(cat "$ACAP_SERVERS_LIST" "$BUILD_SERVERS_LIST" "$FPGA_SERVERS_LIST" "$GPU_SERVERS_LIST" | grep -v "^$hostname$" | sort -u && printf '\0')

#get target host
#target_host=""
#connected=""
#for server in "${remote_servers[@]}"; do
#    # Check connectivity to the current server
#    if [[ "$(check_connectivity "$interface_name" "$server")" == "1" ]]; then
#        target_host="$server"
#        break
#    fi
#done

#update remote_server in config_parameters
#sed -i "/^remote_server/s/xxxx-xxxxx-xx/$target_host/" "$DIR/config_parameters"

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