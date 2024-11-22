#!/bin/bash

#inputs
GITHUB_CLI_PATH=$1
GITHUB_REPO=$2
GITHUB_TAG=$3

exists=""

#check if the tag exists
exists=$($GITHUB_CLI_PATH/gh api repos/$GITHUB_REPO/git/ref/tags/$GITHUB_TAG 2>/dev/null | jq -r 'if has("ref") then "1" else "0" end')

echo "$exists"