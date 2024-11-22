#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

# Check if Docker is installed
if ! which docker > /dev/null 2>&1; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check for docker_developers (containerroot)
member=$($CLI_PATH/common/is_member $USER containerroot)
if [ "$member" = "0" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#run docker hello world
docker run hello-world