#include "qdma/pcie_driver_handler.hpp"

namespace vrt{

    PcieDriverHandler& PcieDriverHandler::getInstance() {
        static PcieDriverHandler instance;
        return instance;
    }

    void PcieDriverHandler::execute(Command cmd) {
        std::string cmdStr = commandToString(cmd);
        int fd = open("/dev/pcie_hotplug", O_WRONLY);
        if (fd < 0) {
            throw std::runtime_error("Could not open device");
        }

        if (write(fd, cmdStr.c_str(), cmdStr.size()) < 0) {
            close(fd);
            throw std::runtime_error("Could not write to device");
        }
        close(fd);
    }

    std::string PcieDriverHandler::commandToString(Command cmd) {
        switch (cmd) {
            case Command::REMOVE: return "remove";
            case Command::TOGGLE_SBR: return "toggle_sbr";
            case Command::RESCAN: return "rescan";
            case Command::HOTPLUG: return "hotplug";
            default: throw std::invalid_argument("Invalid command");
        }
    }
}