#include <ap_fixed.h>
#include <hls_stream.h>

void dma(ap_uint<32> size, hls::stream<ap_uint<32>>& axis_in, ap_uint<32>* out) {
#pragma hls interface mode=s_axilite port=size
#pragma hls interface mode=axis port=axis_in
#pragma hls interface m_axi bundle=gmem0 port=out max_widen_bitwidth=64
#pragma hls interface mode=s_axilite port=return

    for(ap_uint<32> i = 0; i < size; i++) {
        #pragma HLS pipeline II=1
        ap_uint<32> val;
        axis_in.read(val);
        out[i] = val;
    }
}