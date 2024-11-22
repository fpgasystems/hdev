#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
#TMP_PATH="/tmp"

#copy as devices_acap_fpga_coyote
sudo cp -f $DEVICES_LIST ${DEVICES_LIST}_coyote

#remove all columns except first and second
sudo sed -i 's/^\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*/\1 \2/' "${DEVICES_LIST}_coyote"

#remove function (everything after .)
sudo sed -i 's/\..*//g' "${DEVICES_LIST}_coyote"

#replace ":" with a blank space
sudo sed -i 's/:/ /g; s/\.[^.]*$//' "${DEVICES_LIST}_coyote"

#insert an equal
sudo sed -i 's/:/ /g; s/\..*//; s/  */ = /' "${DEVICES_LIST}_coyote"

#insert a line return at the end
sudo sed -i -e '${/^$/!G}' "${DEVICES_LIST}_coyote"