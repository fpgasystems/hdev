#!/bin/bash

GITHUB_CLI_PATH=$1    # directory, e.g. /usr/bin
GITHUB_REPO=$2        # repo like fpgasystems/hdev
GITHUB_PR=$3          # PR number like 55

$GITHUB_CLI_PATH/gh pr view $GITHUB_PR --repo $GITHUB_REPO > /dev/null 2>&1

if [ $? -eq 0 ]; then
    exists=1
else
    exists=0
fi

echo $exists