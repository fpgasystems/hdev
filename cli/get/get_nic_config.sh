#!/bin/bash

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_network"

#helper functions
split_addresses (){
  #input parameters
  str_ip=$1
  str_mac=$2
  aux=$3
  #save the current IFS
  OLDIFS=$IFS
  #set the IFS to / to split the string at each /
  IFS="/"
  #read the two parts of the string into variables
  read ip0 ip1 <<< "$str_ip"
  read mac0 mac1 <<< "$str_mac"
  #reset the IFS to its original value
  IFS=$OLDIFS
  #print the two parts of the string
  if [[ "$aux" == "0" ]]; then
    echo "$ip0 ($mac0)"
  else
    echo "$ip1 ($mac1)"
  fi
}

#constants (id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC)
#ID_COLUMN=1
#BDF_COLUMN=2
#DEVICE_TYPE_COLUMN=3
#DEVICE_NAME_COLUMN=4
#IP_COLUMN=5
#MAC_COLUMN=6

#inputs (./examine 0 root_port)
device_index=$1
port_index=$2
parameter=$3

#reset
iface=""
STATE=""
CONNECTION=""

#get device addresses
IP=$($CLI_PATH/get/get_nic_device_param $device_index IP)
MAC=$($CLI_PATH/get/get_nic_device_param $device_index MAC)
if [ "$port_index" = "1" ]; then
  IP="${IP%%/*}"
  MAC="${MAC%%/*}"
elif [ "$port_index" = "2" ]; then
  IP="${IP#*/}"
  MAC="${MAC#*/}"
fi

#convert to lowercase
MAC=${MAC,,}
iface=$(ifconfig | awk -v ip="$IP" -v mac="$MAC" '
  /^[a-zA-Z0-9]+:/ { iface=$1 }
  /inet / && $2==ip { ip_found=1 }
  /ether / && $2==mac { mac_found=1 }
  ip_found && mac_found { print iface; exit }
  ' | sed 's/://')

case "$parameter" in
    # id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC  
    DEVICE)
      if [ ! "$iface" = "" ]; then
        echo $iface
      fi
      ;;
    STATE)
      if [ ! "$iface" = "" ]; then
        STATE=$(nmcli dev | grep "$iface" | awk '{print $3}')
        echo $STATE
      fi
      ;;
    CONNECTION)
      if [ ! "$iface" = "" ]; then
        CONNECTION=$(nmcli dev | grep "$iface" | awk '{print $4}')
        echo $SCONNECTIONTATE
      fi
      ;;
    *)
      echo "Unknown parameter $parameter."
      ;;
  esac