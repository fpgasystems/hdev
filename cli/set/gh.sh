#!/bin/bash

#echo ""
#gh auth login
#echo ""

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#capture gh auth status
logged_in=$($CLI_PATH/common/gh_auth_status)

#check on logged_in
if [ "$logged_in" = "0" ]; then 
    echo ""
    gh auth login
    echo ""
else
    echo ""
    gh auth status
    echo ""
    echo "${bold}Would you like logout from your GitHub account (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y") 
                gh auth logout
                break
                ;;
            "n") 
                break
                ;;
        esac
    done
    echo ""
fi