
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)


GITHUB_CLI_PATH=$1
REPO_NAME=$2

open_pr=$($GITHUB_CLI_PATH/gh pr list --repo "$REPO_NAME" --json number --jq 'if length>0 then "1" else "0" end' 2>/dev/null || echo 0)
if [[ "$open_pr" == "0" ]]; then
    echo ""
    $GITHUB_CLI_PATH/gh pr list --repo $REPO_NAME
else
    $GITHUB_CLI_PATH/gh pr list --repo $REPO_NAME
fi
echo ""