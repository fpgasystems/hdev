#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
#MAX_PROMPT_ELEMENTS=10
#INC_STEPS=2
#INC_DECIMALS=2
TEMPLATE="simple"

#get_config_id() {
#    #change directory
#    CONFIGS_PATH=$1/configs
#    cd $CONFIGS_PATH
#    #get configs
#    configs=( "host_config_"* )
#    #get the last configuration name
#    last_config="${configs[-1]}"
#    #extract the number part of the configuration name
#    number_part="${last_config##*_}"  # This will extract the part after the last underscore
#    number=$(printf "%03d" $((10#$number_part + 1)))  # Increment the number and format it as 3 digits with leading zeros
#    #construct the new configuration name
#    config_id="host_config_$number"
#    #change back directory
#    cd ..
#    #return
#    echo $config_id
#}

echo ""
echo "${bold}program_add${normal}"
echo ""

#out-of-the-box programs
#PROGRAMS=("drop" "pass_drop" "simple")

#define DIR (where the script program_add is)
DIR="$(dirname "$(realpath "$0")")"

#get built programs
PROGRAMS=($(awk -F ':=' '/^APPS/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DIR/Makefile"))

#similar to common/new_dialog.sh
echo ""
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

#author: https://github.com/jmoya82