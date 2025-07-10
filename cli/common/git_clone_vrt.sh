#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
AVED_TAG=$2
pullrq_id=$3

#constants
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
VRT_REPO=$($CLI_PATH/common/get_constant $CLI_PATH VRT_REPO)

#derived
VRT_REPO="https://github.com/$VRT_REPO.git"

#print
echo "${bold}Checking out AVED:${normal}"
echo ""

#change directory
cd $DIR

#clone repository
git clone $VRT_REPO

#change to repository directory
cd $DIR/SLASH

#checkout the specific tag
if [ $pullrq_id = "none" ]; then
    git checkout tags/$AVED_TAG > /dev/null 2>&1
else
    echo ""
    echo "${bold}Processing pull-request:${normal}"
    echo ""
    echo "$GITHUB_CLI_PATH/gh pr checkout $pullrq_id"
    echo ""
    $GITHUB_CLI_PATH/gh pr checkout $pullrq_id
fi

#update submodules
git submodule update --init --recursive

#echo "target:  /home/jmoyapaya/my_projects/vrt/v1.1.1/today_9/submodules/v80-vitis-flow/submodules/aved"
#echo "current: $DIR/submodules/v80-vitis-flow/submodules/aved/"

#applies the patch for original AVED
cd $DIR/SLASH/submodules/v80-vitis-flow/submodules/aved/
git apply ../../../../deploy/aved.patch

#remove the repository (in case we add it later to our own repository)
rm -rf .git

if [ $pullrq_id = "none" ]; then
    echo ""
    echo "Checkout tag ${bold}$AVED_TAG${normal} done!"
    echo ""
else
    echo ""
    echo "Checkout to pull request #$pullrq_id ${bold}$AVED_TAG${normal} done!"
    echo ""
fi