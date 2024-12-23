#include <ap_fixed.h>
#include <hls_stream.h>

void offset(ap_uint<32> size, ap_uint<32>* input, hls::stream<ap_uint<32> >& axis_out, ap_uint<32> m, ap_uint<32> n) {
#pragma hls interface mode=s_axilite port=size
#pragma hls interface m_axi bundle=gmem0 port=input max_widen_bitwidth=64
#pragma hls interface axis port=axis_out
#pragma hls interface mode=s_axilite port=m
#pragma hls interface mode=s_axilite port=n
#pragma hls interface mode=s_axilite port=return

    for(ap_uint<32> i = 0; i < size; i++) {
#pragma HLS PIPELINE II=1
        ap_uint<32> val = input[i];
        val = val * m + n;
        axis_out.write(val);
    }
}