#include "api/device.hpp"

namespace vrt {

    Device::Device(const std::string& bdf, const std::string& vrtbinPath, bool program) : vrtbin(vrtbinPath, bdf), clkWiz(nullptr, "", 0, 0, 0) {
        this->bdf = bdf;
        this->systemMap = this->vrtbin.getSystemMapPath();
        this->pdiPath = this->vrtbin.getPdiPath();
        auto& qdmaIntf = QdmaIntf::getInstance(bdf);
        createAmiDev();
        
        if(program) {
            programDevice();
        } else {
            //bootDevice();
        }
        // Add pcie hotplug via driver
        // sendPcieDriverCmd("hotplug");
        // system("sudo /usr/local/bin/setup_queues.sh"); // change this??
        parseSystemMap();
        this->clkWiz.setRateHz(clockFreq, false);
    }

    Device::~Device() {
        //destroyAmiDev();
    }

    void Device::parseSystemMap() {
        XMLParser parser(systemMap);
        parser.parseXML();
        clockFreq = parser.getClockFrequency();
        this->clkWiz = ClkWiz(dev, "clk_wiz", 0x20100010000, 0x10000, clockFreq);
        kernels = parser.getKernels();
        for(auto& kernel : kernels) {
            kernel.second.setDevice(dev);
        }
    }
    Kernel Device::getKernel(const std::string& name) {
        return kernels[name];
    }

    void Device::cleanup() {
        ami_dev_delete(&dev);
    }

    std::string Device::getBdf() {
        return bdf;
    }

    void Device::programDevice() {
        char current_uuid[33];
        std::string logic_uuid = vrtbin.getUUID();
        int found_current_uuid = AMI_STATUS_ERROR;
        found_current_uuid = ami_dev_read_uuid(dev, current_uuid);
        if(found_current_uuid == AMI_STATUS_OK) {
            std::string current_uuid_str(current_uuid);
            current_uuid_str = current_uuid_str.substr(0, 32);
            std::cout << "Current UUID: " << current_uuid_str << std::endl;
            std::cout << "New UUID: " << logic_uuid << std::endl;
            if(current_uuid_str == logic_uuid) {
                std::cout << "Device already programmed with the same image" << std::endl;
                bootDevice();
                return;
            }
        }
        std::cout << "Programming device...This might take a while" << std::endl;
        if(ami_prog_download_pdi(dev, pdiPath.c_str(), 0, 1, nullptr) != AMI_STATUS_OK) {
            throw std::runtime_error("Failed to program device");
        }
        bootDevice();
    }

    void Device::sendPcieDriverCmd(std::string cmd) {
        int fd = open("/dev/pcie_hotplug", O_WRONLY);
        if(fd < 0) {
            throw std::runtime_error("Could not open device");
        }

        if(write(fd, cmd.c_str(), cmd.size()) < 0) {
            throw std::runtime_error("Could not write to device");
        }
        close(fd);
    }

    void Device::bootDevice() {
        std::cout << "Booting device..." << std::endl;
        int ret = ami_prog_device_boot(&dev, 1);
        if(ret != AMI_STATUS_OK && geteuid() == 0) { // for root users this should not matter
            throw std::runtime_error("Failed to boot device");
        }
        else {
            std::cout << "Booting into new PDI..." << std::endl;
            ami_mem_bar_write(dev, 0, 0x1040000, 1);
            destroyAmiDev();
            PcieDriverHandler& pcieHandler = PcieDriverHandler::getInstance();
            pcieHandler.execute(PcieDriverHandler::Command::REMOVE);
            usleep(1000);
            pcieHandler.execute(PcieDriverHandler::Command::TOGGLE_SBR);
            usleep(5000000);
            pcieHandler.execute(PcieDriverHandler::Command::RESCAN);
            pcieHandler.execute(PcieDriverHandler::Command::HOTPLUG);
            createAmiDev();
            std::cout << "New PDI booted successfully" << std::endl;
            system("sudo /opt/hdev/cli/program/aved_qdma_add c4:00.1");
            std::cout << "QDMA queues setup successfully" << std::endl;
        }
    }

    void Device::getNewHandle() {
        ami_device *new_dev = NULL;
        int ret = AMI_STATUS_ERROR;
        ret = ami_dev_find_next(&new_dev, AMI_PCI_BUS(pci_bdf), AMI_PCI_DEV(pci_bdf), AMI_PCI_FUNC(pci_bdf), NULL);
        if(ret == AMI_STATUS_OK) {
            if(ami_sensor_discover(new_dev) == AMI_STATUS_OK) {
                dev = new_dev;
            } else {
                throw std::runtime_error("Failed to discover sensors");
            }
        } else {
            throw std::runtime_error("Failed to find device");
        }
    }

    void Device::createAmiDev() {
        if(ami_dev_find(bdf.c_str(), &dev) != AMI_STATUS_OK) {
            throw std::runtime_error("Failed to find device");
        }
        ami_dev_get_pci_bdf(dev, &pci_bdf);
        if(ami_dev_request_access(dev) != AMI_STATUS_OK) {
            throw std::runtime_error("Failed to request elevated access to device");
        }
    }

    void Device::destroyAmiDev() {
        ami_dev_delete(&dev);
    }

    void Device::setFrequency(uint64_t freq) {
        clkWiz.setRateHz(freq);
    }
} // namespace vrt
