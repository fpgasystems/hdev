#!/bin/bash

#username=$1
#workflow=$2

MY_PROJECT_PATH=$1

# Declare global variables
declare -g xclbin_found="0"
declare -g xclbin_name=""
declare -g multiple_xclbins="0"

#get xclbins
cd $MY_PROJECT_PATH/src/xclbin
#echo $MY_PROJECT_PATH/src/xclbin
#echo $pwd
xclbins=( *".cpp" )

#delete ".cpp" from xclbins
j=0
for i in "${xclbins[@]}"
do
    aux[j]=${i::-4} # remove the last four characters, i.e. ".cpp"
    j=$(($j + 1))
done

#Dynamically add the third option (all xclbins) when there is more than one
#if [ ${#aux[@]} -ge 2 ]; then
#    IFS=,  # Set the Internal Field Separator to comma
#    third_option=$(printf "%s, " "${aux[@]}")  # Join elements with a comma and a space
#    IFS=  # Reset the Internal Field Separator
#    third_option=${third_option%, }  # Remove trailing comma and space
#    aux+=( "$third_option" )
#fi

# Check if there is only one xclbin
if [ ${#aux[@]} -eq 1 ]; then
    xclbin_found="1"
    xclbin_name=${aux[0]}
else
    multiple_xclbins="1"
    PS3=""
    select xclbin_name in "${aux[@]}"; do
        if [[ -z $xclbin_name ]]; then
            echo "" >&/dev/null
        else
            xclbin_found="1"
            break
        fi
    done
fi

# Return the values of xclbin_found and xclbin_name
echo "$xclbin_found"
echo "$xclbin_name"
echo "$multiple_xclbins"