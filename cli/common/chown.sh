#!/bin/bash

USER=$1
GROUP=$2
FILE=$3

sudo chown $USER:$GROUP $FILE