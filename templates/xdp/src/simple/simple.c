// SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)
#include <bpf/bpf.h>
#include <bpf/btf.h>
#include <bpf/libbpf.h>
#include <fcntl.h>
#include <linux/if_link.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <unistd.h>

#include <net/if.h>

#ifndef __USE_POSIX
#define __USE_POSIX
#endif
#include <signal.h>

#include "log.h"

// Include skeleton file
#include "simple.skel.h"

static int ifindex_iface1 = 0;
static __u32 xdp_flags = 0;

static void cleanup_iface() {
  __u32 curr_prog_id;
  if (!bpf_xdp_query_id(ifindex_iface1, xdp_flags, &curr_prog_id)) {
    if (curr_prog_id) {
      bpf_xdp_detach(ifindex_iface1, xdp_flags, NULL);
      log_info("Detached XDP program from interface %d", ifindex_iface1);
    }
  }
}

void sigint_handler(int sig_no) {
  cleanup_iface();
  exit(0);
}

int main(int argc, const char **argv) {
  struct simple_bpf *skel = NULL;
  int err;
  const char *iface1 = NULL;

  if (argc < 2) {
    log_error("No iface specified");
    return EXIT_FAILURE;
  }

  iface1 = argv[1];
  log_info("XDP program will be attached to %s interface", iface1);
  ifindex_iface1 = if_nametoindex(iface1);
  if (!ifindex_iface1) {
    log_fatal("Error while retrieving the ifindex of %s", iface1);
    exit(1);
  } else {
    log_info("Got ifindex for iface: %s, which is %d", iface1, ifindex_iface1);
  }

  /* Open BPF application */
  skel = simple_bpf__open();
  if (!skel) {
    log_fatal("Error while opening BPF skeleton");
    exit(1);
  }

  /* Set program type to XDP */
  bpf_program__set_type(skel->progs.xdp_pass_func, BPF_PROG_TYPE_XDP);

  /* Load and verify BPF programs */
  if (simple_bpf__load(skel)) {
    log_fatal("Error while loading BPF skeleton");
    exit(1);
  }

  struct sigaction action;
  memset(&action, 0, sizeof(action));
  action.sa_handler = &sigint_handler;

  if (sigaction(SIGINT, &action, NULL) == -1) {
    log_error("sigation failed");
    goto cleanup;
  }

  if (sigaction(SIGTERM, &action, NULL) == -1) {
    log_error("sigation failed");
    goto cleanup;
  }

  xdp_flags = 0;
  xdp_flags |= XDP_FLAGS_DRV_MODE;
  xdp_flags |= XDP_FLAGS_UPDATE_IF_NOEXIST;

  /* Attach the XDP program to the interface */
  err = bpf_xdp_attach(ifindex_iface1, bpf_program__fd(skel->progs.xdp_pass_func), xdp_flags, NULL);

  if (err) {
    log_fatal("Error while attaching XDP program to the interface");
    exit(1);
  }

  log_info("Successfully attached!");

  // Sleep for 20 minutes to allow for testing to be done
  sleep(1200);

cleanup:
  cleanup_iface();
  simple_bpf__destroy(skel);

  return 0;
}
