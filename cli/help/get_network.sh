#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

echo ""
echo "${bold}$CLI_NAME get network [flags] [--help]${normal}"
echo ""
echo "Networking information for adaptive devices."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --port${normal}      - Specifies the port number for the network adapter."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""