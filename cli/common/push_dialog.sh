#!/bin/bash

#username=$1
#workflow=$2

#MY_PROJECTS_PATH=$1
#WORKFLOW=$2
#COMMIT_NAME=$3

# Declare global variables
declare -g push_option=""
#declare -g new_name=""

while true; do
    read -p "" yn
    case $yn in
        "y") 
            #echo ""
            #create GitHub repository and clone directory
            #gh repo create $project_name --public --clone
            push_option="1"
            break
            ;;
        "n") 
            #create plain directory
            #mkdir $DIR
            push_option="0"
            break
            ;;
    esac
done

# Return the values of project_found and project_name
echo "$push_option"
#echo "$new_name"