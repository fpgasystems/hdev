#!/bin/bash

set -euo pipefail

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
HDEV_PATH="/opt/$CLI_NAME"

is_build=$($CLI_PATH/common/is_build $CLI_PATH $(hostname -s))

if [ "$is_build" = "0" ]; then
  # server is a deployment server
  exec $HDEV_PATH/login/login_deployment.sh
else
  # server is a build server
  exec $HDEV_PATH/login/login_build.sh
fi

# This part should never be reached
echo "ERROR(login.sh): Something went wrong. Please notify the cluster maintainer."
exit 1
