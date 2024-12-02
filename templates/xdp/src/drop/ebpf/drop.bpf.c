// SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)
#include <linux/bpf.h>
#include <linux/types.h>

#include <bpf/bpf_helpers.h>

SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx) {
  return XDP_DROP;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
