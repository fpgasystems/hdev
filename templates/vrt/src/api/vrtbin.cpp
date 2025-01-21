#include "api/vrtbin.hpp"

namespace vrt {
    Vrtbin::Vrtbin(std::string vrtbinPath, const std::string& bdf) {
        this->vrtbinPath = vrtbinPath;
        this->systemMapPath = getenv("AMI_HOME") + bdf + "/system_map.xml";
        this->versionPath = getenv("AMI_HOME") + bdf + "/version.json";
        this->pdiPath = tempExtractPath + "/design.pdi";
        extract();
        extractUUID();
    }

    void Vrtbin::extract() {
        std::string command = "tar -xvf " + vrtbinPath + " -C " + tempExtractPath;
        std::array<char, 128> buffer;
        std::string result;

        std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(command.c_str(), "r"), pclose);
        if (!pipe) {
            throw std::runtime_error("popen() failed!");
        }

        while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
            result += buffer.data();
        }

        int status = pclose(pipe.release());
        if (status == -1) {
            perror("pclose");
        } else {}
        
        copy(tempExtractPath + "/system_map.xml", systemMapPath);
        copy(tempExtractPath + "/version.json", versionPath);

    }

    void Vrtbin::copy(const std::string& source, const std::string& destination) {
        std::ifstream src(source, std::ios::binary);
        if (!src) {
            std::cerr << "Error opening source file: " << source << std::endl;
            throw std::runtime_error("Error opening source file");
        }

        std::ofstream dest(destination, std::ios::binary);
        if (!dest) {
            std::cerr << "Error opening destination file: " << destination << std::endl;
            throw std::runtime_error("Error opening destination file");
        }

        dest << src.rdbuf();

        if (!src) {
            std::cerr << "Error reading from source file: " << source << std::endl;
            throw std::runtime_error("Error reading from source file");
        }

        if (!dest) {
            std::cerr << "Error writing to destination file: " << destination << std::endl;
            throw std::runtime_error("Error writing to destination file");
        }
    }

    std::string Vrtbin::getSystemMapPath() {
        return systemMapPath;
    }
    std::string Vrtbin::getPdiPath() {
        return pdiPath;
    }

    std::string Vrtbin::getUUID() {
        return uuid;
    }

    void Vrtbin::extractUUID() {
        std::ifstream jsonFile(tempExtractPath + "/version.json");
        if (!jsonFile.is_open()) {
            uuid = "";
        }
        std::string line;
        while (std::getline(jsonFile, line)) {
            std::size_t pos = line.find("\"logic_uuid\":");
            if (pos != std::string::npos) {
                std::size_t start = line.find("\"", pos + 13) + 1;
                std::size_t end = line.find("\"", start);
                uuid = line.substr(start, end - start);
                break;
            }
        }

        jsonFile.close();
    }

}