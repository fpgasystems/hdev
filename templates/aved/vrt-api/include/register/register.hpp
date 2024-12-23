#ifndef REGISTER_HPP
#define REGISTER_HPP
#include <string>
#include <cstdint>

namespace vrt {

    /**
     * @brief Class representing a hardware register.
     */
    class Register {
        std::string registerName; ///< Name of the register
        uint32_t offset; ///< Offset of the register
        uint32_t width; ///< Width of the register
        std::string rw; ///< Read/Write permissions of the register
        std::string description; ///< Description of the register

    public:
        /**
         * @brief Constructor for Register.
         * @param registerName The name of the register.
         * @param offset The offset of the register.
         * @param width The width of the register.
         * @param rw The read/write permissions of the register.
         * @param description The description of the register.
         */
        Register(std::string registerName, uint32_t offset, uint32_t width, std::string rw, std::string description);

        /**
         * @brief Default constructor for Register.
         */
        Register() = default;

        /**
         * @brief Gets the name of the register.
         * @return The name of the register.
         */
        std::string getRegisterName();

        /**
         * @brief Gets the offset of the register.
         * @return The offset of the register.
         */
        uint32_t getOffset();

        /**
         * @brief Gets the width of the register.
         * @return The width of the register.
         */
        uint32_t getWidth();

        /**
         * @brief Gets the read/write permissions of the register.
         * @return The read/write permissions of the register.
         */
        std::string getRW();

        /**
         * @brief Gets the description of the register.
         * @return The description of the register.
         */
        std::string getDescription();

        /**
         * @brief Sets the name of the register.
         * @param registerName The name of the register.
         */
        void setRegisterName(std::string registerName);

        /**
         * @brief Sets the offset of the register.
         * @param offset The offset of the register.
         */
        void setOffset(uint32_t offset);

        /**
         * @brief Sets the width of the register.
         * @param width The width of the register.
         */
        void setWidth(uint32_t width);

        /**
         * @brief Sets the read/write permissions of the register.
         * @param rw The read/write permissions of the register.
         */
        void setRW(std::string rw);

        /**
         * @brief Sets the description of the register.
         * @param description The description of the register.
         */
        void setDescription(std::string description);
    };
} // namespace vrt

#endif // REGISTER_HPP