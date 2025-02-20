#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
max_2M=$2
max_1G=$3

echo ""
echo "${bold}$CLI_NAME set hugepages [--help]${normal}"
echo ""
echo "Sets the number of 2MB or 1G hugepages."
echo ""
echo "FLAGS:"
echo "   ${bold}-p, --pages${normal}     - Hugepages number between 1 and ${bold}$max_2M${normal} (2M) or ${bold}$max_1G${normal} (1G)."
echo "   ${bold}-s, --size${normal}      - Use 2M for 2-megabyte pages or 1G for 1-gigabyte pages."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""