#include <iostream>
#include "api/device.hpp"
#include "api/buffer.hpp"
#include "api/kernel.hpp"
#include <chrono>
int main() {
    try {
        uint32_t size = 1024 * 1024;
        std::cout << "Size is: " << size * 8 / 1024 / 1024 << "MB" << std::endl;
        vrt::Device device("21:00.0", "system_map.xml");
        vrt::Kernel example_1(device, "test_example1");
        vrt::Buffer<uint64_t> in_buffer(size, vrt::MemoryRangeType::HBM);
        //std::cout << "Buffer phys addr: "  << std::hex << in_buffer.getPhysAddr() << std::endl;
        vrt::Buffer<uint64_t> out_buffer(size, vrt::MemoryRangeType::HBM);
        //std::cout << "Buffer phys addr: "  << std::hex << out_buffer.getPhysAddr() << std::endl;
        for (size_t i = 0; i < size; ++i) {
            in_buffer[i] = static_cast<uint64_t>(i);
        }
        auto start = std::chrono::high_resolution_clock::now();
        in_buffer.sync(vrt::SyncType::HOST_TO_DEVICE);
        auto end = std::chrono::high_resolution_clock::now();
        std::cout << "Host to device time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
        example_1.write(0x10, size);
        example_1.write(0x18, in_buffer.getPhysAddr() & 0xFFFFFFFF); // start of hbm
        example_1.write(0x1c, (in_buffer.getPhysAddr() >> 32) & 0xFFFFFFFF); // start of hbm

        example_1.write(0x24, out_buffer.getPhysAddr() & 0xFFFFFFFF); // start of hbm
        example_1.write(0x28, (out_buffer.getPhysAddr() >> 32) & 0xFFFFFFFF); // start of hbm
        example_1.start(false);
        start = std::chrono::high_resolution_clock::now();
        example_1.wait();
        end = std::chrono::high_resolution_clock::now();
        std::cout << "Kernel run time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
        start = std::chrono::high_resolution_clock::now();
        out_buffer.sync(vrt::SyncType::DEVICE_TO_HOST);
        end = std::chrono::high_resolution_clock::now();
        std::cout << "Device to host time: " << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "us" << std::endl;
        for(size_t i = 0; i < size; ++i) {
            if(out_buffer[i] != in_buffer[i]*2) {
                std::cerr << "Error: " << i << " " << out_buffer[i] << " " << in_buffer[i] << std::endl;
                device.cleanup();
                std::cout << "Test failed" << std::endl;
                return 0;
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