#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil build aved --project $project_name --tag                            $tag_name --version $vivado_version --all $all 
#example: /opt/sgrt/cli/sgutil build aved --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --version          2022.2 --all    1 

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
project_name=$2
tag_name=$4
vivado_version=$6
all=$8

#all inputs must be provided
if [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$vivado_version" = "" ] || [ "$all" = "" ]; then
    exit
fi

#constants
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"
DIR_PACKAGE="$DIR/sw/AMI/output"

#get AVED example design name (amd_v80_gen5x8_23.2_exdes_2)
aved_name=$(echo "$tag_name" | sed 's/_[^_]*$//')

#project files
pdi_project_name="${aved_name}.$vivado_version.pdi"
pdi_name="${aved_name}_nofpt.pdi"

#bitstream compilation is only allowed on CPU (build) servers
if [ "$all" = "1" ]; then
    #check on bitstream configuration
    are_equals="0"
    if [ -f "$DIR/.device_config" ]; then
        are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    fi

    compile="0"
    if [ ! -e "$DIR/$pdi_project_name" ]; then
        compile="1"
    elif [ -e "$DIR/$pdi_project_name" ] && [ "$are_equals" = "0" ] && [ "$project_name" != "validate_aved.$hostname.$tag_name.$vivado_version" ]; then
        #echo ""
        echo "The Programmable Device Image ${bold}$pdi_project_name${normal} already exists. Do you want to remove it and compile it again (y/n)?"
        while true; do
            read -p "" yn
            case $yn in
                "y")
                    rm -f $DIR/$pdi_project_name 
                    rm -rf $DIR/hw/$aved_name/build 
                    compile="1"
                    break
                    ;;
                "n") 
                    #compile="0"
                    break
                    ;;
            esac
        done
        echo ""
    fi

    #launch vivado
    if [ "$compile" = "1" ]; then 
        #PDI (hardware) compilation
        echo "${bold}Programmable Device Image (PDI) compilation:${normal}"
        echo ""
        echo "cd $DIR/hw/$aved_name"
        echo "./build_all.sh"
        echo ""
        cd $DIR/hw/$aved_name
        ./build_all.sh

        #copy to project folder
        if [ -f "$DIR/hw/$aved_name/build/$pdi_name" ]; then
            #save to project
            cp "$DIR/hw/$aved_name/build/$pdi_name" "$DIR/$pdi_project_name"

            #.device_config
            cp $DIR/configs/device_config $DIR/.device_config
            chmod a-w "$DIR/.device_config"

            #print message
            echo ""
            echo "${bold}$pdi_project_name is done!${normal}"
            echo ""
        fi
    fi
fi

#building driver, API, CLI App
#echo "${bold}Building driver, API, and CLI App:${normal}"
#echo ""
#echo "cd $DIR/sw/AMI"
#echo "./scripts/build.sh"
#echo ""
#cd $DIR/sw/AMI
#./scripts/build.sh -no_workspace

#cleanup timestamp folders (we only want the one that will be generated)
rm -r $DIR_PACKAGE/*/ 2>/dev/null

#generating .deb
echo "${bold}Building Debian package:${normal}"
echo ""
echo "cd $DIR/sw/AMI"
echo "python3 scripts/gen_package.py"
echo ""

#create package
cd $DIR/sw/AMI
python3 scripts/gen_package.py

#get current timestamp
timestamp=$(basename "$DIR/sw/AMI/output"/*/)

#copy .deb to project folder
cp $DIR_PACKAGE/$timestamp/ami_*.deb $DIR/$aved_name.$vivado_version.deb

#get package_name
package_name=$(basename "$DIR_PACKAGE/$timestamp"/ami_*.deb)

echo "The package ${bold}$package_name${normal} was generated!"
echo ""

#building driver, API, CLI App
#echo "${bold}Building driver, API, and CLI App:${normal}"
#echo ""
#echo "cd $DIR/sw/AMI"
#echo "./scripts/build.sh"
#echo ""
#cd $DIR/sw/AMI
#./scripts/build.sh -no_workspace

#echo ""

echo "${bold}Copying files to project folder:${normal}"
echo ""
#echo "Debian pakage artifacts:"
#echo ""
echo "$aved_name.$vivado_version.deb"
echo "$aved_name.$vivado_version.pdi"
echo ""
#echo "Driver, API, and CLI App artifacts:"
#echo ""
#echo "ami.ko"
#echo "ami_tool"
#echo "libami.a"
#echo ""

#cp "$DIR/sw/AMI/api/build/libami.a" "$DIR/libami.a"
#cp "$DIR/sw/AMI/app/build/ami_tool" "$DIR/ami_tool"
#cp "$DIR/sw/AMI/driver/ami.ko" "$DIR/ami.ko"

#author: https://github.com/jmoya82