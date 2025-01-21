TARGET=ip
DEVICE=xcv80-lsva4737-2MHP-e-S

all:
	vitis_hls build.tcl -tclargs $(TARGET) $(DEVICE) increment
	vitis_hls build.tcl -tclargs $(TARGET) $(DEVICE) accumulate

clean:
	rm -r build_$(TARGET) vitis_hls.log