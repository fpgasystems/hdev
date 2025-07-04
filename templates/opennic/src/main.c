#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    int flags_error = 0;
    int config_index = 0;
    int device_index = 0;
    int ping_error = 0;

    // Check and process command-line flags
    flags_error = flags_check(argc, argv, &config_index); //, &device_index

    // Get a valid OpenNIC device from shell configuration file
    device_index = get_first_onic_device("sh.cfg");
    if (device_index == -1) {
        fprintf(stderr, "No 'onic' device found.\n");
        return 1;
    }

    if (flags_error == 0) {
        // read from device_config (index is set to zero)
        int num_cmac_port = atoi(read_parameter(0, "num_cmac_port"));
        
        // read from configuration
        char *remote_server = read_parameter(config_index, "remote_server");
        int num_pings = atoi(read_parameter(config_index, "NUM_PINGS"));   
        
        // Iterate over each CMAC port
        for (int i = 1; i <= num_cmac_port; i++) {
            // get IP
            char *device_ip = get_network(device_index, i);
            
            // get interface name
            char *interface_name = get_interface_name(device_ip);
            
            // Perform ping operation
            ping_error = ping(interface_name, remote_server, num_pings);

            if (ping_error != 0) {
                return 1;
            }
        }
        
        return 0;
    } else {
        print_help();
        return 1;
    }
}