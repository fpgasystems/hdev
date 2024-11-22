#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
TEMPLATE="vadd"

cd $MY_PROJECT_PATH/configs
#exclude config_parameters (we can add other pipes for additional exclusions)
#configs=( $(ls -d host_config_* | grep -v "config_parameters") )

configs=()
for file in host_config_*; do
  if [[ -e $file && $file != *config_parameters* ]]; then
    configs+=("$file")
  fi
done

# Remove file extension from each element in the array
#for ((i=0; i<${#configs[@]}; i++)); do
#    configs[i]=${configs[i]%.cpp}
#done

#there are not configurations
if [ ${#configs[@]} -eq 0 ]; then
    exit
fi

echo ""
echo "${bold}config_delete${normal}"
echo ""
echo "${bold}Please, choose the configuration you want to delete:${normal}"
echo ""

#select configuration
if [ ${#configs[@]} -eq 1 ]; then
    config="host_config_001"
    echo $config 
else
    PS3=""
    select config in "${configs[@]}"; do
        if [[ -z $config ]]; then
            echo "" >&/dev/null
        else
            #project_found="1"
            #project_name=${project_name::-1} # remove the last character, i.e. "/"
            break
        fi
    done
fi

echo ""
echo "${bold}You are about to delete $config. Do you want to continue (y/n)?${normal}"
while true; do
    read -p "" yn
    case $yn in
        "y") 
            rm -f $config
            echo ""
            echo "The configuration ${bold}$config${normal} has been removed!"
            echo ""
            break
            ;;
        "n") 
            break
            ;;
    esac
done