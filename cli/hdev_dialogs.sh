#!/bin/bash

CHECK_ON_GH_TAG_ERR_MSG="Please, choose a valid tag ID."
CHECK_ON_NEW_MSG="${bold}Please, type a non-existing name for your project:${normal}"
CHECK_ON_PROJECT_ERR_MSG="Please, choose a valid project name."
CHECK_ON_PROJECT_EMPTY_ERR_MSG="Please, create a project first."
CHECK_ON_PROJECT_MSG="${bold}Please, choose your project:${normal}"
CHECK_ON_PUSH_ERR_MSG="Please, choose a valid push option."
CHECK_ON_PUSH_MSG="${bold}Would you like to add the project to your GitHub account (y/n)?${normal}"

new_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  new_found=""
  new_name=""

  if [ "$flags_array" = "" ]; then
    #new_dialog
    echo $CHECK_ON_NEW_MSG
    echo ""
    result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
    new_found=$(echo "$result" | sed -n '1p')
    new_name=$(echo "$result" | sed -n '2p')
    echo ""
  else
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $new_found = "0" ]]; then
        echo $CHECK_ON_NEW_MSG
        echo ""
        result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
        new_found=$(echo "$result" | sed -n '1p')
        new_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
  fi
}

new_check(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")
  #new_dialog_check
  result="$("$CLI_PATH/common/new_dialog_check" "${flags_array[@]}")"
  new_found=$(echo "$result" | sed -n '1p')
  new_name=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$new_found" = "1" ] && ([ "$new_name" = "" ] || [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name" ]); then 
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

project_check_empty(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local commit_name=$4

  if [ -z "$(ls -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name"/*/ 2>/dev/null)" ]; then
    echo ""
    echo $CHECK_ON_PROJECT_EMPTY_ERR_MSG
    echo ""
    exit 1
  fi
}

project_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  #local command=$3
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  
  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi
  
  if [ "$flags_array" = "" ]; then
    #project_dialog
    if [[ $project_found = "0" ]]; then
      echo $CHECK_ON_PROJECT_MSG
      echo ""
      result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
      project_found=$(echo "$result" | sed -n '1p')
      project_name=$(echo "$result" | sed -n '2p')
      multiple_projects=$(echo "$result" | sed -n '3p')
      if [[ $multiple_projects = "0" ]]; then
          echo $project_name
      fi
      echo ""
    fi
  else
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo $CHECK_ON_PROJECT_MSG
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
        echo ""
    fi
  fi
}

project_check() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  

  #evaluate current directory
  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi

  #find project name
  result="$("$CLI_PATH/common/project_dialog_check" "${flags_array[@]}")"
  project_found=$(echo "$result" | sed -n '1p')
  project_path=$(echo "$result" | sed -n '2p')
  project_name=$(echo "$result" | sed -n '3p')

  #check if the project exists for WORKFLOW and commit/tag_name
  if [ ! "$project_name" = "" ] && [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]; then
      project_found="1"
      return 1
  fi

  #forbidden combinations
  if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$project_path" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then  
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

push_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  push_found=""
  push_option=""

  #capture gh auth status
  logged_in=$($CLI_PATH/common/gh_auth_status)

  if [ "$flags_array" = "" ]; then
    #push_dialog
    push_option="0"
    if [ "$logged_in" = "1" ]; then
        echo $CHECK_ON_PUSH_MSG
        push_option=$($CLI_PATH/common/push_dialog)
        echo ""
    fi
  else
    push_check "$CLI_PATH" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $push_found = "0" ]]; then
        push_option="0"
        if [ "$logged_in" = "1" ]; then
            echo $CHECK_ON_PUSH_MSG
            push_option=$($CLI_PATH/common/push_dialog)
            echo ""
        fi
    fi
  fi
}

push_check(){
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  #push_dialog_check
  result="$("$CLI_PATH/common/push_dialog_check" "${flags_array[@]}")"
  push_found=$(echo "$result" | sed -n '1p')
  push_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [[ "$push_found" = "1" && "$push_option" != "0" && "$push_option" != "1" ]]; then 
      echo ""
      echo "$CHECK_ON_PUSH_ERR_MSG"
      echo ""
      exit 1
  fi
}

tag_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local MY_PROJECTS_PATH=$3
  local command=$4 #program
  local WORKFLOW=$5 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$6
  local REPO_ADDRESS=$7
  local DEFAULT_TAG=$8
  shift 8
  local flags_array=("$@")
  
  tag_found=""
  tag_name=""
  if [ "$flags_array" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    tag_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$tag_name" ]; then 
        tag_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
    #elif [ "$tag_name" = "$WORKFLOW" ]; then
    #    tag_found="1"
    #    tag_name="${PWD##*/}"
    else
        tag_found="1"
        tag_name=$DEFAULT_TAG
    fi
  else
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$WORKFLOW" "$GITHUB_CLI_PATH" "$REPO_ADDRESS" "$DEFAULT_TAG" "${flags_array[@]}"
  fi
}

tag_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3 #program
  local WORKFLOW=$4 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$5
  local REPO_ADDRESS=$6
  local DEFAULT_TAG=$7
  shift 7
  local flags_array=("$@")
  #commit_dialog_check
  result="$("$CLI_PATH/common/github_tag_dialog_check" "${flags_array[@]}")"
  tag_found=$(echo "$result" | sed -n '1p')
  tag_name=$(echo "$result" | sed -n '2p')
  #check if commit exists
  exists=$($CLI_PATH/common/gh_tag_check $GITHUB_CLI_PATH $REPO_ADDRESS $tag_name)
  #forbidden combinations
  if [ "$tag_found" = "0" ]; then 
    tag_found="1"
    tag_name=$DEFAULT_TAG
  elif [ "$tag_found" = "1" ] && ([ "$tag_name" = "" ] || [ "$exists" = "0" ]); then 
      echo ""
      echo $CHECK_ON_GH_TAG_ERR_MSG
      echo ""
      exit 1
  fi
}