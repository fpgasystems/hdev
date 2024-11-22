#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil build c --source     $program_path 
#example: /opt/sgrt/cli/sgutil build c --source my_program_path.c

#inputs
my_program_path=$2

#get file extension and program name
extension=".${my_program_path##*.}"
program_name="${my_program_path##*/}"
program_name="${program_name%.*}"
path="${my_program_path%/*}"

#application compilation
echo "${bold}Application compilation:${normal}"
echo ""
if [ "$extension" = ".c" ]; then
    echo "gcc $my_program_path -o $path/$program_name"
    gcc $my_program_path -o $path/$program_name
elif [ "$extension" = ".cpp" ]; then
    echo "g++ $my_program_path -o $path/$program_name"
    g++ $my_program_path -o $path/$program_name
fi
sleep 1

#author: https://github.com/jmoya82