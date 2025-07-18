#!/bin/bash

CLI_PATH="$(dirname "$0")/cli"
CLI_NAME="hdev"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev update --number $pullrq_id
#example: /opt/hdev/cli/hdev update --number       none
#         /opt/hdev/cli/hdev update --number          1

#helper functions
chmod_x() {
    path="$1"
    for file in "$path"/*.sh; do
        chmod +x "$file"
        mv "$file" "${file%.sh}"
    done
}

#early exit
is_sudo=$($CLI_PATH/common/is_sudo $USER)
if [ "$is_sudo" = "0" ]; then
    exit
fi

#inputs
pullrq_id=$2

#all inputs must be provided
if [ "$pullrq_id" = "" ]; then
    exit
fi

#constants
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
REPO_NAME="hdev"
UPDATES_PATH=$($CLI_PATH/common/get_constant $CLI_PATH UPDATES_PATH)

#derived
MAIN_BRANCH_URL="https://api.github.com/repos/fpgasystems/$REPO_NAME/commits/main"
REPO_URL="https://github.com/fpgasystems/$REPO_NAME.git"

#get destination path
installation_path=$(which hdev | xargs dirname | xargs dirname)

#get last commit date on the remote
remote_commit_date=$(curl -s $MAIN_BRANCH_URL | jq -r '.commit.committer.date')

#get installed commit date
local_commit_date=$(cat $HDEV_PATH/COMMIT_DATE)

#convert the dates to Unix timestamps
remote_timestamp=$(date -d "$remote_commit_date" +%s)
local_timestamp=$(date -d "$local_commit_date" +%s)

#compare the timestamps and confirm update
update="0"
if [ ! $pullrq_id = "none" ]; then
    echo ""
    echo "${bold}hdev pullrq${normal}"
    echo ""
    echo "This will checkout ${bold}$REPO_NAME${normal} to its pull request ${bold}#$pullrq_id. Would you like to continue (y/n)?${normal}"
    update=$($CLI_PATH/common/push_dialog)
    echo ""
elif [ "$local_timestamp" -lt "$remote_timestamp" ]; then
    echo ""
    echo "${bold}hdev update${normal}"
    echo ""
    echo "This will update ${bold}$REPO_NAME${normal} to its latest version. ${bold}Would you like to continue (y/n)?${normal}"
    update=$($CLI_PATH/common/push_dialog)
    echo ""
else
    commit_id=$(cat $HDEV_PATH/COMMIT)
    echo ""
    echo "$REPO_NAME is on its latest version ${bold}(commit ID: $commit_id)!${normal}"
    echo ""
fi

#update 
if [ $update = "1" ]; then
  #checkout
  cd $UPDATES_PATH
  git clone $REPO_URL #https://github.com/fpgasystems/hdev.git

  #change to directory
  cd $UPDATES_PATH/$REPO_NAME

  #process pull request
  if [ ! $pullrq_id = "none" ]; then
    echo ""
    echo "${bold}Processing pull-request:${normal}"
    echo ""
    echo "$GITHUB_CLI_PATH/gh pr checkout $pullrq_id"
    echo ""
    $GITHUB_CLI_PATH/gh pr checkout $pullrq_id
  fi

  #get commit ID
  remote_commit_id=$(git rev-parse --short HEAD)
  
  #remove unnecessary files
  rm -f *.md
  rm -f *.png
  rm -rf .git
  rm -fr ./cli/manual
  rm -f ./cli/manual.md
  rm -rf docs
  rm -rf hacc-validation
  rm -f overleaf_export.sh
  rm -rf overleaf
  rm -rf playbooks

  #update COMMIT and COMMIT_DATE
  echo $remote_commit_id > COMMIT
  echo $remote_commit_date > COMMIT_DATE

  #backup files
  echo ""
  echo "${bold}Backing up device files:${normal}"
  cp -rf $CLI_PATH/bitstreams $UPDATES_PATH/$REPO_NAME/backup_bitstreams
  sleep 1
  cp $CLI_PATH/devices_acap_fpga $UPDATES_PATH/$REPO_NAME/backup_devices_acap_fpga
  sleep 1
  cp $CLI_PATH/devices_gpu $UPDATES_PATH/$REPO_NAME/backup_devices_gpu
  sleep 1
  cp $CLI_PATH/devices_network $UPDATES_PATH/$REPO_NAME/backup_devices_network
  sleep 1
  #cp $CLI_PATH/platforminfo $UPDATES_PATH/$REPO_NAME/backup_platforminfo
  #sleep 1
  cp -rf $CLI_PATH/constants $UPDATES_PATH/$REPO_NAME/backup_constants
  sleep 1
  cp -rf $CLI_PATH/cmdb $UPDATES_PATH/$REPO_NAME/backup_cmdb
  sleep 1
  echo "Done!"
  echo ""

  #manage scripts
  chmod_x $UPDATES_PATH/$REPO_NAME/cli
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/build
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/common
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/enable
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/get
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/help
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/new
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/open
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/program
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/run
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/set
  chmod_x $UPDATES_PATH/$REPO_NAME/cli/validate

  #remove old version
  echo "${bold}Removing old version:${normal}"
  sudo rm -rf $installation_path/cli
  sleep 1
  sudo rm -rf $installation_path/templates
  sleep 1
  echo "Done!"
  echo ""
  
  #copy files (from /tmp/hdev to /opt/hdev)
  echo "${bold}Copying new version:${normal}"
  sudo mv $UPDATES_PATH/$REPO_NAME/cli $installation_path/cli
  sleep 1
  sudo mv $UPDATES_PATH/$REPO_NAME/templates $installation_path/templates
  sleep 1
  echo "Done!"
  echo ""
  
  #overwrite bitstreams
  echo "${bold}Restoring device files:${normal}"
  sudo rm -rf $installation_path/cli/bitstreams
  sudo cp -rf $UPDATES_PATH/$REPO_NAME/backup_bitstreams $installation_path/cli/bitstreams
  sleep 1
  #overwrite device related info
  sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_devices_acap_fpga $installation_path/cli/devices_acap_fpga
  sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_devices_gpu $installation_path/cli/devices_gpu
  sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_devices_network $installation_path/cli/devices_network
  #sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_platforminfo $installation_path/cli/platforminfo
  sleep 1
  #overwrite constants
  sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_constants/* $installation_path/cli/constants
  sleep 1
  #overwrite cmdb
  sudo cp -r $UPDATES_PATH/$REPO_NAME/backup_cmdb/* $installation_path/cli/cmdb
  sleep 1
  echo "Done!"
  echo ""

  #copy COMMIT and COMMIT_DATE
  sudo cp -f $UPDATES_PATH/$REPO_NAME/COMMIT $installation_path/COMMIT
  sudo cp -f $UPDATES_PATH/$REPO_NAME/COMMIT_DATE $installation_path/COMMIT_DATE

  #ensure ownership
  sudo chown -R root:root $installation_path
  
  #copying hdev_completion
  sudo mv $installation_path/cli/$CLI_NAME"_completion" /usr/share/bash-completion/completions/$CLI_NAME
  sudo chown root:root /usr/share/bash-completion/completions/$CLI_NAME

  #remove from temporal UPDATES_PATH
  rm -rf $UPDATES_PATH/$REPO_NAME
  sleep 1

  if [ ! $pullrq_id = "none" ]; then
    echo "$REPO_NAME was set to pull request ${bold}#$pullrq_id (commit ID: $remote_commit_id)!${normal}"
    echo ""
  else
    echo "$REPO_NAME was updated to its latest version ${bold}(commit ID: $remote_commit_id)!${normal}"
    echo ""
  fi
fi

#author: https://github.com/jmoya82