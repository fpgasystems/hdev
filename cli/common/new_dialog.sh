#!/bin/bash

#username=$1
#workflow=$2

MY_PROJECTS_PATH=$1
WORKFLOW=$2
COMMIT_NAME=$3

# Declare global variables
declare -g new_found="0"
declare -g new_name=""

while true; do
    read -p "" new_name
    #new_name cannot start with validate_
    #if  [[ $new_name == validate_* ]]; then
    #    new_name=""
    #fi
    DIR="$MY_PROJECTS_PATH/$WORKFLOW/$COMMIT_NAME/$new_name"
    if ! [ -d "$DIR" ]; then
        new_found="1"
        break
    fi
done

# Return the values of project_found and project_name
echo "$new_found"
echo "$new_name"