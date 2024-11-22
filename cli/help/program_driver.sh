#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program driver [flags] [--help]${normal}"
echo ""
echo "Inserts or removes a driver or module into the Linux kernel."
echo ""
echo "FLAGS:"
echo "   ${bold}-i, --insert${normal}    - Full path to the .ko module to be inserted."
echo "   ${bold}-p, --params${normal}    - A comma separated list of module parameters." 
echo "   ${bold}    --remote${normal}    - Local or remote deployment."
echo "   ${bold}    --remove${normal}    - Removes an existing module." 
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""