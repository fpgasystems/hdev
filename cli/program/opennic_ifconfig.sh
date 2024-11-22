#!/bin/bash

eno_onic=$1
mac_address=$2
IP0=$3
netmask=$4

#constants
#NUM_ATTEMPTS=3
UNMANAGED_DEVICES_FILE="/etc/NetworkManager/conf.d/99-unmanaged-devices.conf"

#define a function to check if the IP address is set correctly
check_ip() {
    current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
    [ "$current_ip" != "$IP0" ]
}

#convert the MAC address to lowercase
mac_address=$(echo "$mac_address" | tr '[:upper:]' '[:lower:]')

#update NetworkManager (set interface as unmanaged)
device_to_add="interface-name:$eno_onic"
if [ ! -e "$UNMANAGED_DEVICES_FILE" ]; then
    # Create the file and add the device
    echo -e "[keyfile]\nunmanaged-devices=$device_to_add" > "$UNMANAGED_DEVICES_FILE"
else
    # Extract the current devices
    current_devices=$(grep -oP 'unmanaged-devices=\K.*' "$UNMANAGED_DEVICES_FILE")
    
    # Check if the device is already listed
    if [[ ! $current_devices == *"$device_to_add"* ]]; then
        # Add the new device to the list, comma-separated
        if [ -z "$current_devices" ]; then
            new_devices="$device_to_add"
        else
            new_devices="$current_devices,$device_to_add"
        fi
        
        # Update the file with the new device list
        sed -i "s|unmanaged-devices=.*|unmanaged-devices=$new_devices|" "$UNMANAGED_DEVICES_FILE"
    fi
fi

#reload NetworkManager
sudo systemctl reload NetworkManager

#set IP and MAC with ifconfig
sudo ifconfig $eno_onic down
sleep 1
sudo ifconfig $eno_onic hw ether $mac_address
sleep 1
sudo ifconfig $eno_onic $IP0 netmask $netmask
sleep 1
sudo ifconfig $eno_onic up
sleep 1

#loop for NUM_ATTEMPTS
#for ((attempt=1; attempt<=NUM_ATTEMPTS; attempt++)); do
#    if check_ip; then
#        sudo ifconfig $eno_onic hw ether $mac_address
#        sudo ifconfig $eno_onic $IP0 netmask $netmask
#        sudo ifconfig $eno_onic up
#        sleep 2  # Adding delay to ensure the interface comes up
#    else
#        break  # Exit the loop if the IP address is set correctly
#    fi
#done