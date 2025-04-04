#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
TEMPLATE="simple"

echo ""
echo "${bold}program_add${normal}"
echo ""

#define DIR (where the script program_add is)
DIR="$(dirname "$(realpath "$0")")"

#get built programs
PROGRAMS=($(awk -F ':=' '/^APPS/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DIR/Makefile"))

#similar to common/new_dialog.sh
echo "${bold}Please, type a non-existing name for your program:${normal}"
echo ""
new_found="0"
new_name=""
while true; do
    read -p "" new_name
    if [[ ! " ${PROGRAMS[*]} " =~ " $new_name " ]]; then
        new_found="1"
        break
    fi
done

sleep 1

#create a duplicate in src
cp -r $DIR/src/$TEMPLATE $DIR/src/$new_name

#src update
#ebpf folder
mv $DIR/src/$new_name/ebpf/$TEMPLATE.bpf.c $DIR/src/$new_name/ebpf/$new_name.bpf.c
sed -i "s/simple/$new_name/g" "$DIR/src/$new_name/ebpf/$new_name.bpf.c"
#Makefile
sed -i "s/simple/$new_name/g" "$DIR/src/$new_name/Makefile"
#c file
mv $DIR/src/$new_name/$TEMPLATE.c $DIR/src/$new_name/$new_name.c
sed -i "s/simple/$new_name/g" "$DIR/src/$new_name/$new_name.c"

#top update
sed -i "/^APPS := / s/$/ $new_name/" "$DIR/Makefile"

sleep 2

echo ""
echo "The program ${bold}$new_name.c${normal} has been created!"
echo ""

#author: https://github.com/jmoya82