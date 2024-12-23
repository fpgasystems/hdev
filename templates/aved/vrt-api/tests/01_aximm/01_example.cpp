#include <iostream>
#include <cstring> // for std::memcpy
#include <cstdint>

#include <fcntl.h>
#include <unistd.h>
#include <string>
#include <chrono>

#include "../../include/api/device.hpp"
#include "../../include/api/buffer.hpp"
#include "../../include/api/kernel.hpp"

int main() {
    try {
        uint32_t size = 1024 * 1024;
        uint32_t m = 3;
        uint32_t n = 2;
        vrt::Device device("c4:00.0", "01_example.vrtbin", false);
        vrt::Kernel dma(device, "dma_0");
        vrt::Kernel offset(device, "offset_0");
        device.setFrequency(233333333);
        vrt::Buffer<uint32_t> in_buff(size, vrt::MemoryRangeType::HBM);
        vrt::Buffer<uint32_t> out_buff(size, vrt::MemoryRangeType::HBM);
        for(uint32_t i = 0; i < size; i++) {
            in_buff[i] = 1;
        }
	auto start = std::chrono::high_resolution_clock::now();
        in_buff.sync(vrt::SyncType::HOST_TO_DEVICE);
	auto end = std::chrono::high_resolution_clock::now();
        std::cout << "Host to device time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
        offset.write(0x10, size);
        offset.write(0x18, in_buff.getPhysAddrLow());
        offset.write(0x1c, in_buff.getPhysAddrHigh());
        offset.write(0x24, m);
        offset.write(0x2c, n);
        dma.write(0x10, size);
        dma.write(0x18, out_buff.getPhysAddrLow());
        dma.write(0x1c, out_buff.getPhysAddrHigh());
        offset.start(false);
        dma.start(false);
	start = std::chrono::high_resolution_clock::now();
        offset.wait();
        dma.wait();
	end = std::chrono::high_resolution_clock::now();
	std::cout << "Kernel run time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
	start = std::chrono::high_resolution_clock::now();
        out_buff.sync(vrt::SyncType::DEVICE_TO_HOST);
	end = std::chrono::high_resolution_clock::now();
        std::cout << "Device to host time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
        for(uint32_t i = 0; i < size; i++) {
            if(out_buff[i] != in_buff[i] * m + n) {
                std::cerr << "Test failed" << std::endl;
                std::cerr << "Error: " << i << " " << out_buff[i] << " " << in_buff[i] << std::endl;
                device.cleanup();
                return 1;
            }
        }
        std::cout << "Test passed" << std::endl;
        device.cleanup();
    } catch (const std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return 1;
    } 
    return 0;
}

