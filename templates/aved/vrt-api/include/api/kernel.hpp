#ifndef KERNEL_HPP
#define KERNEL_HPP

#include <string>
#include <ami.h>
#include <ami_mem_access.h>
#include <stdexcept>
#include <vector>

#include "register/register.hpp"

namespace vrt {
    class Device;

    /**
     * @brief Class representing a kernel.
     */
    class Kernel {
        static constexpr uint64_t BASE_BAR_ADDR = 0x20100000000; ///< Base BAR address
        uint8_t bar = 0; ///< Base Address Register (BAR)
        ami_device* dev = nullptr; ///< Pointer to the AMI device
        std::string name; ///< Name of the kernel
        uint64_t baseAddr; ///< Base address of the kernel
        uint64_t range; ///< Address range of the kernel
        std::vector<Register> registers; ///< List of registers in the kernel

    public:
        /**
         * @brief Constructor for Kernel.
         * @param device Pointer to the AMI device.
         * @param name The name of the kernel.
         * @param baseAddr The base address of the kernel.
         * @param range The address range of the kernel.
         * @param registers The list of registers in the kernel.
         */
        Kernel(ami_device* device, const std::string& name, uint64_t baseAddr, uint64_t range, const std::vector<Register>& registers);

        /**
         * @brief Default constructor for Kernel.
         */
        Kernel() = default;

        /**
         * @brief Constructor for Kernel using a Device object.
         * @param device The Device object.
         * @param kernelName The name of the kernel.
         */
        Kernel(vrt::Device device, const std::string& kernelName);

        /**
         * @brief Sets the device for the kernel.
         * @param device Pointer to the AMI device.
         */
        void setDevice(ami_device* device);

        /**
         * @brief Writes a value to a register.
         * @param offset The offset of the register.
         * @param value The value to write.
         */
        void write(uint32_t offset, uint32_t value);

        /**
         * @brief Reads a value from a register.
         * @param offset The offset of the register.
         * @return The value read from the register.
         */
        uint32_t read(uint32_t offset);

        /**
         * @brief Waits for the kernel to complete.
         */
        void wait();

        /**
         * @brief Starts the kernel.
         * @param autorestart Flag indicating whether to enable autorestart.
         */
        void start(bool autorestart=false);

        /**
         * @brief Destructor for Kernel.
         */
        ~Kernel();
    };

} // namespace vrt

#endif // KERNEL_HPP