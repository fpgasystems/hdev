#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1
DIR=$2
COYOTE_COMMIT=$3
pullrq_id=$4

#constants
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
COYOTE_REPO=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_REPO)

#derived
COYOTE_REPO="https://github.com/$COYOTE_REPO.git"

#print
echo "${bold}Checking out Coyote:${normal}"
echo ""

#change directory
cd $DIR

#clone repository
git clone $COYOTE_REPO

#change to repository directory
cd $DIR/Coyote

#checkout the specific tag
if [ $pullrq_id = "none" ]; then
    git checkout $COYOTE_COMMIT > /dev/null 2>&1
else
    echo ""
    echo "${bold}Processing pull-request:${normal}"
    echo ""
    echo "$GITHUB_CLI_PATH/gh pr checkout $pullrq_id"
    echo ""
    $GITHUB_CLI_PATH/gh pr checkout $pullrq_id
fi

#update submodules
#git submodule update --init --recursive

#remove the repository (in case we add it later to our own repository)
rm -rf .git

if [ $pullrq_id = "none" ]; then
    echo ""
    echo "Checkout commit ID ${bold}$COYOTE_COMMIT${normal} done!"
    echo ""
else
    echo ""
    echo "Checkout to pull request #$pullrq_id ${bold}$AVED_TAG${normal} done!"
    echo ""
fi