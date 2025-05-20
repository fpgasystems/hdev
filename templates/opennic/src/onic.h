#ifndef ONIC_H
#define ONIC_H

int flags_check(int argc, char *argv[], int *config_index);
int get_first_onic_device(const char *sh_cfg_path);
char* get_interface_name(char *device_ip);
char* get_network(int device_index, int port_number);
int ping(const char *onic_name, const char *remote_server_name, int num_pings);
void print_help();
char* read_parameter(int index, const char *parameter_name);

#endif