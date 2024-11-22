<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/hdev/tree/main?tab=readme-ov-file#--hacc-development">Back to top</a>
</p>

# Known limitations
* For deployment servers with reconfigurable devices, **it's imperative to maintain a single version of the Xilinx toolset** (comprising XRT, Vivado, and Vitis_HLS) on the system. Multiple versions of these tools should not coexist to ensure proper operation.
* The PCIe hot-plug process (which allows us to transition between Vitis and Vivado workflows effortlessly and without the need of rebooting the system) **is not available on virtualized environments.** This is only relevant for Xilinx Alveo Accelerator Cards.
* For deployment servers with GPUs, **only one version of HIP/ROCm should be installed.**
