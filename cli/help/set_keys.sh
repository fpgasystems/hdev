#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME set keys [--help]${normal}"
echo ""
echo "Creates your RSA key pairs and adds to authorized_keys and known_hosts."
echo ""
echo "FLAGS:"
echo "   This command has no flags."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1