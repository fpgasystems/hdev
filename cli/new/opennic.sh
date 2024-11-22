#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
SGRT_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil new opennic --commit $comit_name_shell $comit_name_driver --project   $new_name --push $push_option
#example: /opt/sgrt/cli/sgutil new opennic --commit            807775            1cf2578 --project hello_world --push            0

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
push_option=$7

#all inputs must be provided
if [ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
ACAP_SERVERS_LIST="$CLI_PATH/constants/ACAP_SERVERS_LIST"
BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"
DEVICES_LIST_NETWORKING="$CLI_PATH/devices_network"
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
GPU_SERVERS_LIST="$CLI_PATH/constants/GPU_SERVERS_LIST"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NETWORKING_DEVICE_INDEX="1"
NETWORKING_PORT_INDEX="1"
WORKFLOW="opennic"

#get devices number
if [ -s "$DEVICES_LIST_NETWORKING" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NETWORKING"
fi

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

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
cp $SGRT_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $SGRT_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $SGRT_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $SGRT_PATH/templates/$WORKFLOW/Makefile $DIR/Makefile
cp -r $SGRT_PATH/templates/$WORKFLOW/configs $DIR
cp -r $SGRT_PATH/templates/$WORKFLOW/src $DIR

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

#update remote_server in config_parameters
sed -i "/^remote_server/s/xxxx-xxxxx-xx/$target_host/" "$DIR/config_parameters"

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