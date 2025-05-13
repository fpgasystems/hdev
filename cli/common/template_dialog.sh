#!/bin/bash

CLI_PATH=$1 
TEMPLATES_FILE=$2 

# Declare global variables
declare -g template_found="0"
declare -g template_name=""

num_templates=$(wc -l < "$CLI_PATH/constants/$TEMPLATES_FILE")

#get device index
if [[ "$num_templates" -eq 1 ]]; then
    template_found="1"
    template_name=$(sed -n '1p' "$CLI_PATH/constants/$TEMPLATES_FILE")
else
    templates=()
    while IFS= read -r line; do
        templates+=("$line")
    done < "$CLI_PATH/constants/$TEMPLATES_FILE"
    PS3=""
    select template_name in "${templates[@]}"; do
        if [[ -z $template_name ]]; then
            echo "" >&/dev/null  # or print an error if desired
        else
            template_found="1"
            break
        fi
    done
fi

#return the values of template_found and template_name
echo "$template_found"
echo "$template_name"