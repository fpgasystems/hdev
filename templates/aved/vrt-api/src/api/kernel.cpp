#include "api/kernel.hpp"
#include "api/device.hpp"
namespace vrt {

    Kernel::Kernel(ami_device* device, const std::string& name, uint64_t baseAddr, uint64_t range, const std::vector<Register>& registers) {
        this->dev = device;
        this->name = name;
        this->baseAddr = baseAddr;
        this->range = range;
        this->registers = registers;
    }

    Kernel::Kernel(Device device, const std::string& kernelName)
        : Kernel(device.getKernel(kernelName)) {}

    void Kernel::write(uint32_t offset, uint32_t value) {
        uint32_t* buf = (uint32_t*) calloc(1, sizeof(uint32_t));
        *buf = value;
        if(buf) {
            // TODO: add bar from device....
            int ret = ami_mem_bar_write(dev, bar, baseAddr - BASE_BAR_ADDR + offset, buf[0]);
            if(ret != AMI_STATUS_OK) {
                throw std::runtime_error("Failed to write to device");
            }
        }
        free(buf);
    }

    uint32_t Kernel::read(uint32_t offset) {
        uint32_t* buf = (uint32_t*) calloc(1, sizeof(uint32_t));
        if(buf) {
            int ret = ami_mem_bar_read(dev, bar, baseAddr - BASE_BAR_ADDR + offset, &buf[0]);
            if(ret != AMI_STATUS_OK) {
                throw std::runtime_error("Failed to read from device");
            }
        }
        uint32_t value = buf[0];
        free(buf);
        return value;
    }

    void Kernel::setDevice(ami_device* device) {
        this->dev = device;
    }

    void Kernel::wait() {
        while((read(0x00) >> 1) & 0x01 != 1) {
            // wait for the kernel to finish
        }

    }

    void Kernel::start(bool autorestart) {
        if(autorestart) {
            write(0x00, 0x81);
        } else {
            write(0x00, 0x01);
        }
    }

    Kernel::~Kernel() {
        // if(dev != nullptr) {
        //     ami_dev_delete(&dev);
        // }
        //ami_dev_delete(&dev);
    }

} // namespace vrt