#include <ap_fixed.h>
#include <hls_stream.h>

void increment(ap_uint<32> size, float* in, hls::stream<float>& axis_out) {
#pragma hls interface mode=s_axilite port=size
#pragma hls interface m_axi bundle=gmem0 port=in max_widen_bitwidth=64
#pragma hls interface axis port=axis_out
#pragma hls interface mode=s_axilite port=return

	for(ap_uint<32> i = 0; i < size; i++) {
	#pragma hls pipeline II=1
			float data = in[i] + 1;
			axis_out.write(data);
	}
}