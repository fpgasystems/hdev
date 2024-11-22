#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$gpu_enabled" = "0" ]; then
    exit 1
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="hip"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

# create my_projects directory
DIR="$MY_PROJECTS_PATH"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

# create hip directory
DIR="$MY_PROJECTS_PATH/$WORKFLOW"
#if ! [ -d "$DIR" ]; then
#    mkdir ${DIR}
#fi
mkdir -p $DIR

# create project
echo ""
echo "${bold}sgutil new hip${normal}"
echo ""
echo "${bold}Please, insert a non-existing name for your HIP project:${normal}"
echo ""
while true; do
    read -p "" project_name
    #project_name cannot start with validate_
    if  [[ $project_name == validate_* ]]; then
        project_name=""
    fi
    DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name"
    if ! [ -d "$DIR" ]; then
        break
    fi
done

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW

#add to GitHub if gh is installed
commit="0"
if [[ $(which gh) ]]; then
    echo ""
    echo "${bold}Would you like to add the repository to your GitHub account (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y") 
                echo ""
                #create GitHub repository and clone directory
                gh repo create $project_name --public --clone
                commit="1"
                break
                ;;
            "n") 
                #create plain directory
                mkdir $DIR
                break
                ;;
        esac
    done
    echo ""
fi

#catch gh repo create error (DIR has not been created)
if ! [ -d "$DIR" ]; then
    echo "Please, start GitHub CLI first using sgutil set gh"
    echo ""
    exit
fi

#copy template from SGRT_PATH
SGRT_PATH=$(dirname "$CLI_PATH")
cp -rf $SGRT_PATH/templates/$WORKFLOW/hello_world/* $DIR
#compile src
cd $DIR/src
g++ -std=c++17 create_config.cpp -o ../create_config >&/dev/null
#g++ -std=c++17 create_data.cpp -o ../create_data

#commit files
if [ "$commit" = "1" ]; then 
    cd $DIR
    #update README.md 
    echo "# "$project_name >> README.md
    #add gitignore
    echo ".DS_Store" >> .gitignore
    #add, commit, push
    git add .
    git commit -m "First commit"
    git push --set-upstream origin master
    echo ""
fi

#echo ""
echo "The project ${bold}$MY_PROJECTS_PATH/$WORKFLOW/$project_name${normal} has been created!"
echo ""