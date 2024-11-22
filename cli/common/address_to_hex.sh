
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#usage: address_to_hex address_type address

address_type=$1
address=$2

case "$address_type" in
    "IP")
        #read
        ip=$address

        #remove .
        ip=${ip//./ }

        #convert
        ip=($ip)
        ip0=$(printf '%02X' ${ip[0]})
        ip1=$(printf '%02X' ${ip[1]})
        ip2=$(printf '%02X' ${ip[2]})
        ip3=$(printf '%02X' ${ip[3]})

        #return
        echo $ip0$ip1$ip2$ip3
        ;;
    "MAC")
        #read
        mac=$address
        
        #convert
        mac_hex=${mac//:/}

        #return
        echo $mac_hex
        ;;
    *)
        echo "Invalid address type. Please provide 'IP' or 'MAC'."
        exit 1
        ;;
esac


