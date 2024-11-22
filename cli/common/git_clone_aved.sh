#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
AVED_TAG=$2

#constants
AVED_REPO=$($CLI_PATH/common/get_constant $CLI_PATH AVED_REPO)

#derived
AVED_REPO="https://github.com/$AVED_REPO.git"

#print
echo "${bold}Checking out AVED:${normal}"
echo ""

#change directory
cd $DIR

#clone repository
git clone $AVED_REPO

#change to repository directory
cd $DIR/AVED

#checkout the specific tag
git checkout tags/$AVED_TAG > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "Checkout tag ${bold}$AVED_TAG${normal} done!"
echo ""