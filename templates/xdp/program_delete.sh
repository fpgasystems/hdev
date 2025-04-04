#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

if [ "$#" -ne 0 ]; then
    echo ""
    echo "Error: ${bold}$(basename "$0")${normal} does not accept parameters."
    echo ""
    exit 1
fi

#define DIR (where the script program_delete is)
DIR="$(dirname "$(realpath "$0")")"

#get all eBPF/XDP programs
folders=($(find "$DIR/src" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))

#check on folders
if [ ${#folders[@]} -eq 0 ]; then
    exit
fi

echo ""
echo "${bold}program_delete${normal}"
echo ""

# Display a menu using select
delete_name=""
PS3=""
echo "${bold}Please, choose your program:${normal}"
echo ""
if [ ${#folders[@]} -eq 1 ]; then
    folder=${folders[0]}
    echo $folder
    echo ""
    echo "${bold}You are about to delete $folder. Do you want to continue (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y") 
                #delete="1"
                delete_name=$folder
                echo ""
                break
                ;;
            "n") 
                echo ""
                break
                ;;
        esac
    done
else
    select folder in "${folders[@]}"; do
        if [[ -n "$folder" ]]; then
            #delete="1"
            delete_name=$folder
            echo ""
            break
        fi
    done
fi

if [ ! "$delete_name" = "" ]; then
    #update Makefile
    sed -i "/^APPS := / s/\b$delete_name\b//" "$DIR/Makefile"
    sed -i "/^APPS := / s/[[:space:]]\+/ /g" "$DIR/Makefile"

    #remove folders
    rm -rf $DIR/src/$delete_name
    rm -rf $DIR/.output/$delete_name
    rm -rf $DIR/$delete_name
    sleep 2
fi