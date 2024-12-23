#include <ap_fixed.h>
#include <hls_stream.h>

void accumulate(ap_uint<32> size, float& out, hls::stream<float>& axis_in) {
#pragma hls interface mode=s_axilite port=size
#pragma hls interface mode=s_axilite port=out
#pragma hls interface mode=axis port=axis_in
#pragma hls interface mode=s_axilite port=return
	float acc = 0;
	for(ap_uint<32> i = 0; i < size; i++) {
	#pragma hls pipeline II=1
			float data;
			axis_in.read(data);
			acc += data;
	}
	out = acc;
}