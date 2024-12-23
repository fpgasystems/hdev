#include "parser/xml_parser.hpp"

namespace vrt {
    XMLParser::XMLParser(const std::string& file_path) {
        this->filename = file_path;   
        this->document = xmlReadFile(this->filename.c_str(), NULL, 0);
        this->rootNode = xmlDocGetRootElement(this->document);
        this->workingNode = rootNode->children;
    }

    
    void XMLParser::parseXML() {
        for (xmlNode* kernelNode = rootNode->children; kernelNode; kernelNode = kernelNode->next) {
            if (kernelNode->type == XML_ELEMENT_NODE && xmlStrcmp(kernelNode->name, BAD_CAST "Kernel") == 0) {
                std::string name;
                std::string baseAddress;
                std::string range;
                std::vector<Register> registers;
                for (xmlNode* childNode = kernelNode->children; childNode; childNode = childNode->next) {
                    if (childNode->type == XML_ELEMENT_NODE) {
                        if (xmlStrcmp(childNode->name, BAD_CAST "Name") == 0) {
                            name = (const char*)xmlNodeGetContent(childNode);
                        } else if (xmlStrcmp(childNode->name, BAD_CAST "BaseAddress") == 0) {
                            baseAddress = (const char*)xmlNodeGetContent(childNode);
                        } else if (xmlStrcmp(childNode->name, BAD_CAST "Range") == 0) {
                            range = (const char*)xmlNodeGetContent(childNode);
                        } else if (xmlStrcmp(childNode->name, BAD_CAST "register") == 0) {
                            std::string offset = (const char*)xmlGetProp(childNode, BAD_CAST "offset");
                            std::string regName = (const char*)xmlGetProp(childNode, BAD_CAST "name");
                            std::string access = (const char*)xmlGetProp(childNode, BAD_CAST "access");
                            std::string description = (const char*)xmlGetProp(childNode, BAD_CAST "description");
                            std::string regRange = (const char*)xmlGetProp(childNode, BAD_CAST "range");
                            Register reg;
                            reg.setOffset(std::stoi(offset, nullptr, 16));
                            reg.setRegisterName(regName);
                            reg.setRW(access);
                            reg.setDescription(description);
                            reg.setWidth(std::stoi(regRange));
                            registers.push_back(reg);
                        }
                    }
                }
                auto ba = std::stoull(baseAddress, nullptr, 16);
                auto r = std::stoull(range, nullptr, 16);
                Kernel kernel((ami_device*)nullptr, name, ba, r, registers);
                kernels[name] = kernel;
            } else if (kernelNode->type == XML_ELEMENT_NODE && xmlStrcmp(kernelNode->name, BAD_CAST "ClockFrequency") == 0) {
                std::string clkFreq = (const char*)xmlNodeGetContent(kernelNode);
                this->clockFrequency = std::stoull(clkFreq);
            }
        }
    }

    std::map<std::string, Kernel> XMLParser::getKernels() {
        return kernels;
    }

    uint64_t XMLParser::getClockFrequency() {
        return this->clockFrequency;
    }

    XMLParser::~XMLParser() {
        if (this->document != nullptr) {
            xmlFreeDoc(this->document);
        }
        xmlCleanupParser();
    }
} // namespace vrt