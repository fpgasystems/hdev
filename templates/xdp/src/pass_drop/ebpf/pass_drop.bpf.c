// SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/icmp.h>
#include <linux/icmpv6.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <linux/in.h>
#include <bpf/bpf_endian.h>

static __always_inline int parse_ethhdr(void *data, void *data_end, __u16 *nh_off,
                                        struct ethhdr **ethhdr) {
  struct ethhdr *eth = (struct ethhdr *)data;
  int hdr_size = sizeof(*eth);

  /* Byte-count bounds check; check if current pointer + size of header
   * is after data_end.
   */
  if ((void *)eth + hdr_size > data_end)
    return -1;

  *nh_off += hdr_size;
  *ethhdr = eth;

  return eth->h_proto; /* network-byte-order */
}

static __always_inline int parse_iphdr(void *data, void *data_end, __u16 *nh_off,
                                       struct iphdr **iphdr) {
  struct iphdr *ip = data;
  int hdr_size;

  if ((void *)ip + sizeof(*ip) > data_end)
    return -1;

  hdr_size = ip->ihl * 4;
  if (hdr_size < sizeof(*ip))
    return -1;
  if ((void *)ip + hdr_size > data_end)
    return -1;

  *nh_off += hdr_size;
  *iphdr = ip;

  return ip->protocol;
}

static __always_inline int parse_icmphdr(void *data, void *data_end, __u16 *nh_off,
                                         struct icmphdr **icmphdr) {
  struct icmphdr *icmp = (struct icmphdr *)data;
  int hdr_size = sizeof(*icmp);

  if ((void *)icmp + hdr_size > data_end)
    return -1;

  *nh_off += hdr_size;
  *icmphdr = icmp;

  return icmp->type;
}

SEC("xdp")
int xdp_pass_func(struct xdp_md *ctx) {
  void *data_end = (void *)(long)ctx->data_end;
  void *data = (void *)(long)ctx->data;

  bpf_printk("Received packet, parsing...");
  __u16 nf_off = 0;
  struct ethhdr *eth;
  int eth_type = parse_ethhdr(data + nf_off, data_end, &nf_off, &eth);
  if (eth_type < 0) {
    bpf_printk("Packet is not a valid Ethernet packet, dropping");
    return XDP_DROP;
  }
  if (eth_type != bpf_htons(ETH_P_IP)) {
    goto pass;
  }

  //this is just for sanity, in the network i tested this i received ethernet frames with really weird eth_type
  bpf_printk("received IP packet with protocol: %d", bpf_ntohs(eth_type));

  bpf_printk("IP packet, parsing...");
  struct iphdr *ip;
  int ip_type = parse_iphdr(data + nf_off, data_end, &nf_off, &ip);
  if (ip_type < 0) {
    bpf_printk("Packet is not a valid IPv4 packet, dropping");
    return XDP_DROP;
  }
  if (ip_type != IPPROTO_ICMP)
    goto pass;

  bpf_printk("ICMP packet, parsing...");
  struct icmphdr *icmphdr;
  int icmp_type = parse_icmphdr(data + nf_off, data_end, &nf_off, &icmphdr);

  if (icmp_type != ICMP_ECHO)
    goto pass;

  __u16 seq = bpf_ntohs(icmphdr->un.echo.sequence);
  if (seq % 2 == 0) {
    bpf_printk("Dropping packet with even sequence number: %d", seq);
    return XDP_DROP;
  }

pass:
  return XDP_PASS;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
