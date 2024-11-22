#!/bin/bash

CLI_PATH="$(dirname "$0")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_sudo" != "1" ] && ! ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
    exit 1
fi

#get username
username=$(getent passwd ${SUDO_UID})
username=${username%%:*}

echo ""

#Loop for countdown
for i in {30..0}; do
    echo -n "."
    sleep 0.5
done

# Print the final message after countdown
echo ""
echo -e "\nSee you later, ${bold}$username!${normal}"
echo ""

#sudo reboot
/sbin/reboot