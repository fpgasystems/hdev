#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
#MAX_PROMPT_ELEMENTS=10
#INC_STEPS=2
#INC_DECIMALS=2

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

echo "Extracted programs: ${PROGRAMS[@]}"

#extend with already existing user programs
#if [ -d "$DIR/.output" ]; then
#    PROGRAMS=($(awk -F ':=' '/^APPS/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DIR/Makefile"))
#fi

#similar to common/new_dialog.sh
echo ""
echo "${bold}Please, type a non-existing name for your project:${normal}"
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

echo "$new_found"
echo "$new_name"


#author: https://github.com/jmoya82