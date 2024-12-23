# VRT (V80 RunTime) API

This repository contains the VRT API implementation, along with 2 examples.
## Dependencies

- AVED software stack (https://github.com/Xilinx/AVED)
- PCIe hotplug driver (https://gitenterprise.xilinx.com/aulmamei/pcie-hotplug-drv)
- Custom QDMA queue creator script (to be added to git)

## How to build

To build an example, one must do the following:

```bash
cd tests/<0X>_example/
./build_all.sh
```

This will build the hardware design for the FPGA, using the HLS kernels provided in the `hls/` directory. Beware, this takes around one hour to finish.

## How to run

In order to run one of the built examples, one must identify the BDF for the V80 and input it into the software.

```
lspci -vd 10ee:
21:00.0 Processing accelerators: Xilinx Corporation Device 50b4
        Subsystem: Xilinx Corporation Device 000e
        Flags: bus master, fast devsel, latency 0, NUMA node 0, IOMMU group 29
        Memory at 2bf40000000 (64-bit, prefetchable) [size=256M]
        Capabilities: <access denied>
        Kernel driver in use: ami
        Kernel modules: ami

21:00.1 Processing accelerators: Xilinx Corporation Device 50b5
        Subsystem: Xilinx Corporation Device 000e
        Flags: bus master, fast devsel, latency 0, NUMA node 0, IOMMU group 29
        Memory at 2bf50000000 (64-bit, prefetchable) [size=512K]
        Capabilities: <access denied>
        Kernel driver in use: qdma-pf
        Kernel modules: qdma_pf, ami, qdma_vf
```

Then, in the example C++ code (`tests/<0X_example/<0X>_example.cpp>`), change the following line with the found BDF number:

```C++
vrt::Device device("21:00.0", "00_example.vrtbin", true);
```

Navigate to the `build` directory, then run:

```bash
make
```
This will re-build the host application. After that, run the example.


## Notes
This software depends on the PCIe hotplug driver (https://gitenterprise.xilinx.com/aulmamei/pcie-hotplug-drv) being installed prior to the running of the software.