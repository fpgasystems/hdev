#include "register/register.hpp"

namespace vrt {

    // Constructor
    Register::Register(std::string registerName, uint32_t offset, uint32_t width, std::string rw, std::string description)
        : registerName(registerName), offset(offset), width(width), rw(rw), description(description) {}

    // Getters

    std::string Register::getRegisterName() {
        return registerName;
    }

    uint32_t Register::getOffset() {
        return offset;
    }

    uint32_t Register::getWidth() {
        return width;
    }

    std::string Register::getRW() {
        return rw;
    }

    std::string Register::getDescription() {
        return description;
    }

    // Setters

    void Register::setRegisterName(std::string registerName) {
        this->registerName = registerName;
    }

    void Register::setOffset(uint32_t offset) {
        this->offset = offset;
    }

    void Register::setWidth(uint32_t width) {
        this->width = width;
    }

    void Register::setRW(std::string rw) {
        this->rw = rw;
    }

    void Register::setDescription(std::string description) {
        this->description = description;
    }

} // namespace vrt