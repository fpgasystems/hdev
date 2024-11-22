#ifndef ONIC_H
#define ONIC_H

int flags_check(int argc, char *argv[], int *config_index, int *device_index);
char* get_interface_name(char *device_ip);
char* get_network(int device_index, int port_number);
void ping(const char *onic_name, const char *remote_server_name, int num_pings);
void print_help();
char* read_parameter(int index, const char *parameter_name);

#endif