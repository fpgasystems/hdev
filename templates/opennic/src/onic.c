#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "onic.h"

// Define valid flags
const char *valid_flags[] = {"-c", "--config", "-d", "--device"};

#define NUM_FLAGS (sizeof(valid_flags) / sizeof(valid_flags[0]))
#define MAX_LINE_LENGTH 256

int flags_check(int argc, char *argv[], int *config_index, int *device_index) {
    int flags_error = 0;

    if (argc != 5) {  // 4 args + program name
        flags_error = 1;
    }

    for (int i = 1; i < argc && !flags_error; i += 2) {
        int valid = 0;

        // Validate the flag against valid_flags
        for (int j = 0; j < NUM_FLAGS; j++) {
            if (strcmp(argv[i], valid_flags[j]) == 0) {
                valid = 1;
                break;
            }
        }

        if (!valid) {
            fprintf(stderr, "Error: Invalid flag %s\n", argv[i]);
            flags_error = 1;
            break;
        }

        if (i + 1 >= argc) {
            fprintf(stderr, "Error: Flag %s must be followed by a value.\n", argv[i]);
            flags_error = 1;
            break;
        }

        // Handle device index conversion to int
        if (strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--device") == 0) {
            *device_index = atoi(argv[i + 1]);
            if (*device_index <= 0) {
                //fprintf(stderr, "Error: Invalid device index %s\n", argv[i + 1]);
                flags_error = 1;
                break;
            }
        } 
        // Handle config index conversion to int
        else if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--config") == 0) {
            *config_index = atoi(argv[i + 1]);
            if (*config_index <= 0) {
                //fprintf(stderr, "Error: Invalid config index %s\n", argv[i + 1]);
                flags_error = 1;
                break;
            }
        }
    }

    // Ensure all necessary parameters were provided
    if (*device_index == 0 || *config_index == 0) {
        //fprintf(stderr, "Error: Missing required parameters.\n");
        flags_error = 1;
    }

    return flags_error;  // Return 0 on success, 1 on error
}

char* get_interface_name(char *device_ip) {
    char command[256];
    snprintf(command, sizeof(command), "ifconfig");

    FILE *fp = popen(command, "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: Failed to run ifconfig command\n");
        return NULL;
    }

    static char interface_name[256];
    char line[256];
    char current_interface[256] = "";  // Store the current interface name
    int ip_found = 0;  // Flag to track if the IP is found

    // Read through the ifconfig output line by line
    while (fgets(line, sizeof(line), fp) != NULL) {
        // Look for lines that define the interface name (these start without leading spaces)
        if (line[0] != ' ') {
            // Capture the interface name and remove any trailing colon
            sscanf(line, "%s", current_interface);
            char *colon_ptr = strchr(current_interface, ':');
            if (colon_ptr != NULL) {
                *colon_ptr = '\0';  // Remove the colon
            }
        }

        // Look for the device_ip in subsequent lines
        if (strstr(line, device_ip) != NULL) {
            // If we find the IP, set the flag and break out of the loop
            ip_found = 1;
            strncpy(interface_name, current_interface, sizeof(interface_name) - 1);
            interface_name[sizeof(interface_name) - 1] = '\0';  // Ensure null-termination
            break;
        }
    }

    pclose(fp);

    // If the IP wasn't found, report an error
    if (!ip_found) {
        fprintf(stderr, "Error: No interface found for IP %s.\n", device_ip);
        return NULL;
    }

    return interface_name;
}

char* get_network(int device_index, int port_number) {
    char command[256];
    snprintf(command, sizeof(command), "sgutil get network --device %d --port %d", device_index, port_number);

    // Open a pipe to the command and read the output
    FILE *fp = popen(command, "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: Failed to run command '%s'\n", command);
        return NULL;
    }

    static char result[256];
    result[0] = '\0'; // Initialize the result as an empty string

    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        // Look for lines that contain an IP address
        char *ip_start = strstr(line, " ");
        if (ip_start != NULL) {
            ip_start += 1; // Skip the space character
            char *ip_end = strchr(ip_start, ' ');
            if (ip_end != NULL) {
                *ip_end = '\0'; // Null-terminate the IP address
                strncpy(result, ip_start, sizeof(result) - 1);
                result[sizeof(result) - 1] = '\0'; // Ensure null-termination
                break; // Exit after finding the first IP address
            }
        }
    }

    // Close the pipe
    pclose(fp);

    // Check if result is still empty (no IP found)
    if (result[0] == '\0') {
        fprintf(stderr, "Error: No valid IP address found in command output.\n");
        return NULL;
    }

    return result;
}

void ping(const char *onic_name, const char *remote_server_name, int num_pings) {
    char command[256];
    snprintf(command, sizeof(command), "ping -I %s -c %d %s", onic_name, num_pings, remote_server_name);
    printf("%s\n", command);
    printf("\n");
    int result = system(command);
    if (result != 0) {
        printf("Ping command failed with exit code %d\n", result);
    }
}

void print_help() {
    FILE *file = fopen("./src/onic_help", "r");
    if (!file) {
        perror("Error: Could not open help file");
        exit(1);
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        printf("%s", line);
    }

    fclose(file);
}

char* read_parameter(int index, const char *parameter_name) {
    char config_file_path[256];
    char line[MAX_LINE_LENGTH];
    
    // Determine the file path based on the index
    if (index == 0) {
        snprintf(config_file_path, sizeof(config_file_path), "./.device_config");
    } else {
        snprintf(config_file_path, sizeof(config_file_path), "./configs/host_config_%03d", index);
    }

    // Open the configuration file
    FILE *file = fopen(config_file_path, "r");
    if (!file) {
        perror("Failed to open config file");
        return NULL;
    }

    // Read each line in the file to search for the parameter
    while (fgets(line, sizeof(line), file)) {
        char param[MAX_LINE_LENGTH];
        char val[MAX_LINE_LENGTH];

        // Try to parse the line as a "key = value" pair
        if (sscanf(line, "%s = %s", param, val) == 2) {
            // Remove any trailing semicolon
            char *semicolon = strchr(val, ';');
            if (semicolon) {
                *semicolon = '\0';
            }

            // If the parameter matches the requested name, return a dynamically allocated value
            if (strcmp(param, parameter_name) == 0) {
                char *result = malloc(strlen(val) + 1);  // Allocate memory for the result
                if (result) {
                    strcpy(result, val);  // Copy the value into the allocated memory
                }
                fclose(file);
                return result;
            }
        }
    }

    // If parameter is not found, return NULL
    fclose(file);
    return NULL;
}