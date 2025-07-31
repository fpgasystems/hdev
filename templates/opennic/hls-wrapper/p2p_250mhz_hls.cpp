#include <ap_axi_sdata.h>
#include <hls_stream.h>

// ref: https://docs.amd.com/r/en-US/ug1399-vitis-hls/How-AXI4-Stream-is-Implemented
// same as hls::axis<ap_int<512>,48,0,0> (so using signed data)
// if unsigned is need use ap_axiu or hls::axis<ap_uint<512>,48,0,0>
//  The numbers represent: ap_axis< Tdata_width, Tuser_width, Tid_width, Tdest_width >
//  From open nic we see that
//    - Tdata_width = 512
//    - Tuser_width = 3*16 = 48
//    - Tid_width   = not defined, so 0
//    - Tdest_width = not defined, so 0
typedef ap_axis<512,48,0,0> pkt_t;


void onic_hls(hls::stream<pkt_t> &tx_in, hls::stream<pkt_t> &tx_out, hls::stream<pkt_t> &rx_in, hls::stream<pkt_t> &rx_out) {
// A free-runing kernel; no control interfaces needed to start the operation
#pragma HLS INTERFACE ap_ctrl_none port=return

#pragma HLS interface axis port=tx_in
#pragma HLS interface axis port=tx_out
#pragma HLS interface axis port=rx_in
#pragma HLS interface axis port=rx_out

  pkt_t tx_packet;
  pkt_t rx_packet;

  if (!tx_in.empty()) {
    tx_packet = tx_in.read();
    tx_out.write(tx_packet);
  }

  if (!rx_in.empty()) {
    rx_packet = rx_in.read();
    rx_out.write(rx_packet);
  }

}