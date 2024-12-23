#ifndef PCIE_DRIVER_HANDLER_HPP
#define PCIE_DRIVER_HANDLER_HPP

#include <string>
#include <stdexcept>
#include <fcntl.h>
#include <unistd.h>

namespace vrt {
    /**
     * @brief Class for handling PCIe driver commands.
     */
    class PcieDriverHandler {
    public:
        /**
         * @brief Enum for PCIe driver commands.
         */
        enum class Command {
            REMOVE, ///< Remove command
            TOGGLE_SBR, ///< Toggle Secondary Bus Reset command
            RESCAN, ///< Rescan command
            HOTPLUG ///< Hotplug command
        };

        /**
         * @brief Gets the singleton instance of the PcieDriverHandler.
         * @return The singleton instance of the PcieDriverHandler.
         */
        static PcieDriverHandler& getInstance();

        /**
         * @brief Deletes the copy constructor.
         */
        PcieDriverHandler(const PcieDriverHandler&) = delete;

        /**
         * @brief Deletes the assignment operator.
         */
        PcieDriverHandler& operator=(const PcieDriverHandler&) = delete;

        /**
         * @brief Sends a command to the PCIe driver.
         * @param cmd The command to send.
         */
        void sendCommand(Command cmd);

        /**
         * @brief Executes a PCIe driver command.
         * @param cmd The command to execute.
         */
        void execute(Command cmd);

    private:
        /**
         * @brief Private constructor to prevent instantiation.
         */
        PcieDriverHandler() {}

        /**
         * @brief Helper method to convert enum to string.
         * @param cmd The command to convert.
         * @return The string representation of the command.
         */
        std::string commandToString(Command cmd);
    };

} // namespace vrt
#endif // PCIE_DRIVER_HANDLER_HPP