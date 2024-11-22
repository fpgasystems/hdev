#!/bin/bash

CLI_PATH=$1
bold=$(tput bold)
normal=$(tput sgr0)

#inputs
servers=("${@:2}")

# create key
echo "${bold}Creating id_rsa private and public keys:${normal}"
echo ""
FILE="/home/$USER/.ssh/id_rsa.pub"
if ! [ -f "$FILE" ]; then
    #create key
    eval "ssh-keygen"

    #add id_rsa.pub to authorized_keys 
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    echo ""
    echo "Done!"
    echo ""
else
    echo "The key already exists."
    echo ""
fi

#create if does not exist
[ -f ~/.ssh/known_hosts ] || touch ~/.ssh/known_hosts

if [ ${#servers[@]} -ne 0 ]; then
    ## add SSH (mellanox-0) fingerprints to local known_hosts
    echo "${bold}Adding fingerprints to known_hosts:${normal}"
    
    #booked servers
    for i in "${servers[@]}"
    do
        echo ""
        ssh-keygen -R $i > /dev/null
        ssh-keyscan -H $i >> ~/.ssh/known_hosts
        sleep 1
    done
    echo ""
fi

#author: https://github.com/jmoya82