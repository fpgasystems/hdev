#!/bin/bash

#user_name=$1
#team_name=$2

#constants
organization_name="oreolag"

#gh_check
logged_in=$($CLI_PATH/common/gh_auth_status)
if [ "$logged_in" = "0" ]; then 
  exit 1
fi

#get gh user
user_name=$(gh api user --jq '.login')

#check on user
state=$(gh api "/orgs/$organization_name/memberships/$user_name" 2>/dev/null | jq -r '.state' | grep -w "active")
if [ "$state" = "active" ]; then
    echo "1"
else
    echo "0"
fi