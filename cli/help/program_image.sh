#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program image [flags] [--help]${normal}"
echo ""
echo "Programs a Programmable Device Image (PDI) to a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}    --partition${normal} - Partition Index; if omitted, image loads to volatile memory." 
echo "   ${bold}    --path${normal}      - Full path to the .pdi image to be programmed." 
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""