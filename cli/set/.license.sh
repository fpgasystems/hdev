#!/bin/bash

#early exit
if [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

if [ "$#" -ne 2 ]; then
    set_license_help
    exit 1
fi

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "0" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

eval "$CLI_PATH/set/license-msg"