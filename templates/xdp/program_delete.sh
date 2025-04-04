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
PS3=""
echo "${bold}Please, choose your program:${normal}"
echo ""
select folder in "${folders[@]}"; do
    if [[ -n "$folder" ]]; then
        delete_name=$folder
        echo ""
        break
    fi
done

#update Makefile
sed -i "/^APPS := / s/\b$delete_name\b//" "$DIR/Makefile"
sed -i "/^APPS := / s/[[:space:]]\+/ /g" "$DIR/Makefile"

#remove folders
rm -rf $DIR/src/$delete_name
rm -rf $DIR/.output/$delete_name
rm -rf $DIR/$delete_name
sleep 2