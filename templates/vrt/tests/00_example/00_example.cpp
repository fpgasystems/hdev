#include <iostream>
#include <cstring> // for std::memcpy
#include <random>
#include "../../include/api/device.hpp"
#include "../../include/api/buffer.hpp"
#include "../../include/api/kernel.hpp"

int main() {
    try {
        uint32_t size = 2048;
        vrt::Device device("c4:00.0", "00_example.vrtbin", true);
        device.setFrequency(250000000);
        vrt::Kernel accumulate(device, "accumulate_0");
        vrt::Kernel increment(device, "increment_0");
        vrt::Buffer<float> buffer(size, vrt::MemoryRangeType::DDR);
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<> dis(0.0, 1.0);

        float goldenModel = 0;
        for(uint32_t i = 0; i < size; i++) {
            buffer[i] = static_cast<float>(dis(gen));
            goldenModel+=buffer[i] + 1;
        }

        buffer.sync(vrt::SyncType::HOST_TO_DEVICE);
        increment.write(0x10, size);
        increment.write(0x18, buffer.getPhysAddr() & 0xFFFFFFFF);
        increment.write(0x1c, (buffer.getPhysAddr() >> 32) & 0xFFFFFFFF);
        accumulate.write(0x10, size);
        increment.start(false);
        accumulate.start(false);
        increment.wait();
        accumulate.wait();
        uint32_t val = accumulate.read(0x18);
        float floatVal;
        std::memcpy(&floatVal, &val, sizeof(float));
        if(std::fabs(goldenModel - floatVal) > 0.0001) {
            std::cerr << "Test failed!" << std::endl;
            std::cout << "Expected: " << goldenModel << std::endl;
            std::cout << "Got: " << floatVal << std::endl;
            device.cleanup();
            return 1;
        } else {
            std::cout << "Expected: " << goldenModel << std::endl;
            std::cout << "Got: " << floatVal << std::endl;
            std::cout << "Test passed!" << std::endl;
        }
        
        device.cleanup();

    } catch (const std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return 1;
    } 
    return 0;
}
