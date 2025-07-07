#!/bin/bash

#inputs
GITHUB_CLI_PATH=$1       # path to the GitHub CLI, e.g., "/usr/bin/gh"
GITHUB_REPO=$2           # e.g., "fpgasystems/SLASH"
GITHUB_PR=$3             # e.g., "42"

#check if the PR exists
exists=$("$GITHUB_CLI_PATH" pr view "$GITHUB_PR" --repo "$GITHUB_REPO" --json number 2>/dev/null | jq -r 'if has("number") then "1" else "0" end')

echo "$exists"