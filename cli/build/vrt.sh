#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev build vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version
#example: /opt/hdev/cli/hdev build vrt --project   hello_world --tag    v1.0.0 --target       hw_all --version          2024.2

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
project_name=$2
tag_name=$4
target_name=$6
vivado_version=$8

#all inputs must be provided
if [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$target_name" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vrt"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#get template name
VRT_TEMPLATE=$(cat $DIR/VRT_TEMPLATE)

#modify Makefile
sed -i 's|^V80PP_PATH=$(shell realpath ../../submodules/v80-vitis-flow)$|V80PP_PATH=$(shell realpath ../submodules/v80-vitis-flow)|' $DIR/src/Makefile

#bitstream compilation is only allowed on CPU (build) servers
compile="0"
if [ "$target_name" = "emu_all" ] || [ "$target_name" = "sim_all" ]; then
    #always allowed without user input
    rm -rf $target_name.$VRT_TEMPLATE.$vivado_version
    compile="1"
elif [ "$target_name" = "hw_all" ] && [ "$is_build" = "1" ]; then
    #check on bitstream configuration
    #are_equals="0"
    #if [ -f "$DIR/.device_config" ]; then
    #    are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    #fi

    #compile="0"
    if [ ! -d "$target_name.$VRT_TEMPLATE.$vivado_version" ]; then
        compile="1"
    else
        #echo ""
        echo "The target ${bold}$target_name${normal} has already been compiled. Do you want compile it again (y/n)?"
        while true; do
            read -p "" yn
            case $yn in
                "y")
                    rm -rf $target_name.$VRT_TEMPLATE.$vivado_version
                    compile="1"
                    break
                    ;;
                "n") 
                    break
                    ;;
            esac
        done
        echo ""
    fi
fi

if [ "$compile" = "1" ]; then
    echo "${bold}Programmable Device Image (PDI) compilation (tag ID: $tag_name)${normal}"
    echo ""
    echo "cd $DIR/src && make $target_name"
    echo ""
    cd $DIR/src && make $target_name
    echo ""

    #move build folder
    mv $DIR/src/build $DIR/$target_name.$VRT_TEMPLATE.$vivado_version

    #cleanup to allow re-compiling
    rm -rf $DIR/src/hls/build_*

    #send email
    if [ ! -d "$target_name.$VRT_TEMPLATE.$vivado_version" ] && [ "$target_name" = "hw_all" ]; then  
        user_email=$USER@ethz.ch
        echo "Subject: Good news! hdev build vrt ($target_name.$VRT_TEMPLATE.$vivado_version) is done!" | sendmail $user_email
    fi
fi

#move relevant files
if [ "$target_name" = "sim_all" ]; then
    #$DIR/sim_all.00_axilite.2024.2/v80-vitis-flow/build/sim/sim_prj/sim_prj.xpr
    ln -s $DIR/$target_name.$VRT_TEMPLATE.$vivado_version/v80-vitis-flow/build/sim/sim_prj/sim_prj.xpr $DIR/$target_name.$VRT_TEMPLATE.$vivado_version/sim_prj.xpr
fi

#compile driver
#echo "${bold}Driver compilation (commit ID: $commit_name_driver)${normal}"
#echo ""
#echo "cd $DRIVER_DIR && make"
#echo ""
#cd $DRIVER_DIR && make
#echo ""

#application compilation
echo "${bold}Application compilation:${normal}"
echo ""
echo "cd $DIR/src && make app"
echo ""
cd $DIR/src && make app
echo ""

#copy application files
cp -rf "$DIR/src/build/." "$DIR/$target_name.$VRT_TEMPLATE.$vivado_version/"
rm -rf $DIR/src/build/

#copy driver
#cp -f $DRIVER_DIR/$DRIVER_NAME $DIR/$DRIVER_NAME

#remove drivier files (generated while compilation)
#rm $DRIVER_DIR/Module.symvers
#rm -rf $DRIVER_DIR/hwmon
#rm $DRIVER_DIR/modules.order
#rm $DRIVER_DIR/$DRIVER_NAME
#rm $DRIVER_DIR/onic.mod
#rm $DRIVER_DIR/onic.mod.c
#rm $DRIVER_DIR/onic.mod.o
#rm $DRIVER_DIR/onic.o
#rm $DRIVER_DIR/onic_common.o
#rm $DRIVER_DIR/onic_ethtool.o
#rm $DRIVER_DIR/onic_hardware.o
#rm $DRIVER_DIR/onic_lib.o
#rm $DRIVER_DIR/onic_main.o
#rm $DRIVER_DIR/onic_netdev.o
#rm $DRIVER_DIR/onic_sysfs.o

#author: https://github.com/jmoya82