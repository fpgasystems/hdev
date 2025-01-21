#!/bin/bash

MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
MAX_PROMPT_ELEMENTS=10
INC_STEPS=2
INC_DECIMALS=2

get_config_id() {
    #change directory
    CONFIGS_PATH=$1/configs
    cd $CONFIGS_PATH
    #get configs
    configs=( "host_config_"* )
    #get the last configuration name
    last_config="${configs[-1]}"
    #extract the number part of the configuration name
    number_part="${last_config##*_}"  # This will extract the part after the last underscore
    number=$(printf "%03d" $((10#$number_part + 1)))  # Increment the number and format it as 3 digits with leading zeros
    #construct the new configuration name
    config_id="host_config_$number"
    #change back directory
    cd ..
    #return
    echo $config_id
}

generate_selectable_values() {
    local min="$1"
    local max="$2"
    local inc="$3"
    local precision="$INC_DECIMALS"

    # Initialize an empty array for selectable values
    local selectable_values=()

    # Initialize loop variable as floating-point number
    local value="$min"

    # Loop until the value exceeds the max
    while (( $(echo "$value <= $max" | bc -l) )); do
        # Check if the value starts with "."
        if [[ "${value:0:1}" == "." ]]; then
            # If it starts with ".", prepend "0" before the value
            value="0$value"
        fi
        
        # Append the value to the array
        selectable_values+=("$value")

        # Apply precision formatting for decimal increments
        if [[ "$inc" =~ \. ]]; then
            value=$(printf "%.${precision}f" "$value")
        fi
        
        # Increment the value using bc for floating-point arithmetic
        value=$(echo "$value + $inc" | bc -l)
    done

    # Print the selectable values separated by spaces
    echo "${selectable_values[*]}"
}

validate_input() {
    
    #get inputs
    local input="$1"
    local selectable_values="$2"

    #check if the input is one of the selectable values
    for value in $selectable_values; do
        if [[ "$input" == "$value" ]]; then
            #echo "$input"
            return 0
        fi
    done

    #print an error message (if wanted)
    return 1
}

add_to_config_file() {
    local config_id="$1"
    local parameter_i="$2"
    local selected_value="$3"

    # Append the parameter and its selected value to the configuration file
    if [[ -n "$selected_value" ]]; then
        echo "$parameter_i = $selected_value;" >> "$MY_PROJECT_PATH/configs/$config_id"
    fi
}

find_existing_parameter() {
    local parameter_i="$1"

    # Loop through the parameters_aux array
    for parameter_value in "${parameters_aux[@]}"; do
        # Extract the parameter name and value from each element
        parameter_name="${parameter_value%% = *}"
        value="${parameter_value#* = }"

        # Check if the parameter name matches the specified parameter_i
        if [[ "$parameter_name" == "$parameter_i" ]]; then
            # If a match is found, return the corresponding value
            echo "$value"
            return 0
        fi
    done

    # If the parameter is not found or doesn't contain letters, return an empty string ==> return $max $min $inc
    echo "$1"
    return 1
}

is_integer() {
    local value="$1"
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "1"  # Return "1" for integer
    else
        echo "0"  # Return "0" for non-integer
    fi
}

# Function to read parameters, ranges, and descriptions from a file
read_parameters() {
    local input_file="$1"
    # Initialize arrays
    parameters=()
    ranges=()
    descriptions=()

    # Read each line from the input file
    while read -r line; do
        column_1=$(echo "$line" | awk '{print $1}')
        column_2=$(echo "$line" | awk '{print $2}')
        column_3=$(echo "$line" | awk '{print $3}')
        parameters+=("$column_1")
        ranges+=("$column_2")
        descriptions+=("$column_3")
    done < "$input_file"
}

# Function to write configuration based on parameters and ranges
write_config() {
    local output_file="$1"
    shift
    local param_count=$#
    local parameters=("${@:1:$(($param_count / 2))}")
    local ranges=("${@:$(($param_count / 2 + 1))}")

    for ((i = 0; i < ${#parameters[@]}; i++)); do
        local parameter_i="${parameters[i]}"
        local ranges_i="${ranges[i]}"
        
        local min=""
        local max=""
        local inc=""
        local list=""
        local constant=""
        local selectable_values=""
        local selected_value=""
        local selectable_values_prompt=""
        
        case "$ranges_i" in
            *:*)
                local colon_count=$(grep -o ":" <<< "$ranges_i" | wc -l)
                if [[ $colon_count -eq 1 ]]; then
                    IFS=':' read -r min max <<< "$ranges_i"
                    min=$(find_existing_parameter "$min")
                    max=$(find_existing_parameter "$max")
                    local is_integer_min=$(is_integer "$min")
                    local is_integer_max=$(is_integer "$max")

                    if [[ "$is_integer_min" == "1" && "$is_integer_max" == "1" ]]; then
                        inc="1"
                    elif [[ "$is_integer_min" == "0" && "$is_integer_max" == "0" ]]; then
                        inc=$(echo "scale=$INC_DECIMALS; ($max - $min) / $INC_STEPS" | bc)
                    fi

                elif [[ $colon_count -eq 2 ]]; then
                    min="${ranges_i%%:*}"
                    local remaining="${ranges_i#*:}"
                    inc="${remaining%%:*}"
                    max="${remaining#*:}"
                    min=$(find_existing_parameter "$min")
                    inc=$(find_existing_parameter "$inc")
                    max=$(find_existing_parameter "$max")
                fi

                selectable_values=$(generate_selectable_values "$min" "$max" "$inc")
                local num_elements=$(echo "$selectable_values" | wc -w)

                if (( num_elements > MAX_PROMPT_ELEMENTS )); then
                    if [[ "$inc" == "1" ]]; then
                        selectable_values_prompt="$min .. $max"
                    else
                        selectable_values_prompt="$min:$inc:$max"
                    fi
                else
                    selectable_values_prompt="$selectable_values"
                fi
                ;;
            *","*)
                selectable_values=$(echo "$ranges_i" | tr "," " ")
                selectable_values_prompt="$selectable_values"
                ;;
            *)
                selected_value="$ranges_i"
                ;;
        esac

        if [[ -n "$selectable_values_prompt" ]]; then
            read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
            while ! validate_input "$selected_value" "$selectable_values"; do
                read -rp "$parameter_i [$selectable_values_prompt]: " selected_value
            done
        fi

        add_to_config_file "$output_file" "$parameter_i" "$selected_value"
        parameters_aux+=("$parameter_i = $selected_value")
    done
}

echo ""

#get config_id
config_id=$(get_config_id $MY_PROJECT_PATH)

#we avoid host_config_000 is created when configs is empty
if [[ "$config_id" == "host_config_000" ]]; then
    config_id="host_config_001"
fi

#get device and host parameters
awk '/^device:/, /^$/{if (!/^device:/ && $0 != "") print}' $MY_PROJECT_PATH/config_parameters > $MY_PROJECT_PATH/device_parameters
awk '/^host:/, /^$/{if (!/^host:/ && $0 != "") print}' $MY_PROJECT_PATH/config_parameters > $MY_PROJECT_PATH/host_parameters

#device
msg=""
create_device_config="1"
if [ -f "$MY_PROJECT_PATH/configs/device_config" ]; then
    echo "${bold}A device_config file already exists. Do you want to remove it and create a new one (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y")
                msg="${bold}device_config${normal} has been updated"
                break
                ;;
            "n") 
                create_device_config="0"
                break
                ;;
        esac
    done
    echo ""
fi

#store already declared parameters
declare -a parameters_aux

if [ "$create_device_config" == "1" ]; then
    #create configuration file
    rm -f "$MY_PROJECT_PATH/configs/device_config"
    touch $MY_PROJECT_PATH/configs/device_config

    #read from parameters
    read_parameters "$MY_PROJECT_PATH/device_parameters"

    #create configuration
    echo "${bold}Device parameters:${normal}"
    echo ""
    write_config "device_config" "${parameters[@]}" "${ranges[@]}"
    
    #change permissions (we avoid that user directly uses vi)
    chmod a-w "$MY_PROJECT_PATH/configs/device_config"
    echo ""
fi

#host
create_host_config="1"
if [ -n "$msg" ]; then
    echo "${bold}Do you want to create a host configuration as well (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y")
                break
                ;;
            "n") 
                create_host_config="0"
                break
                ;;
        esac
    done
    echo ""
fi

if [ "$create_host_config" == "1" ]; then
    #create configuration file
    touch $MY_PROJECT_PATH/configs/$config_id

    #read from parameters
    read_parameters "$MY_PROJECT_PATH/host_parameters"

    #create configuration
    echo "${bold}Host parameters:${normal}"
    echo ""
    write_config "$config_id" "${parameters[@]}" "${ranges[@]}"

    #change permissions (we avoid that user directly uses vi)
    chmod a-w "$MY_PROJECT_PATH/configs/$config_id"
    echo ""
fi

#print message
if [[ "$create_device_config" == "1" ]]; then
    if [[ -z "$msg" ]]; then
        msg="The configurations ${bold}device_config${normal} and ${bold}$config_id${normal} have been created!${normal}"
    else
        if [ "$create_host_config" == "1" ]; then
            msg="$msg; ${bold}$config_id${normal} has been created!"
        else
            msg="$msg!"
        fi
    fi
else
    if [[ -z "$msg" ]]; then
        msg="The configuration ${bold}$config_id${normal} has been created!"
    else
        msg="$msg ${bold}$config_id${normal} has been created!"
    fi
fi
echo "$msg"
echo ""


#remove host_config_000 if exists
if [ -f "$MY_PROJECT_PATH/configs/host_config_000" ]; then
    rm "$MY_PROJECT_PATH/configs/host_config_000"
fi

#remove temporal files
rm -f $MY_PROJECT_PATH/device_parameters
rm -f $MY_PROJECT_PATH/host_parameters

#author: https://github.com/jmoya82