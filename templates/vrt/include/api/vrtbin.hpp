#ifndef VRTBIN_HPP
#define VRTBIN_HPP

#include <string>
#include <cstdlib>
#include <array>
#include <fstream>
#include <iostream>
#include <memory>

namespace vrt {

    /**
     * @brief Class for handling VRTBIN operations.
     */
    class Vrtbin {
        std::string vrtbinPath; ///< Path to the VRTBIN file
        std::string systemMapPath; ///< Path to the system map file
        std::string versionPath; ///< Path to the version file
        std::string pdiPath; ///< Path to the PDI file
        std::string uuid; ///< UUID of the VRTBIN
        std::string tempExtractPath = "/tmp"; ///< Temporary extraction path

        /**
         * @brief Copies a file from source to destination.
         * @param source The source file path.
         * @param destination The destination file path.
         */
        void copy(const std::string& source, const std::string& destination);

    public:
        /**
         * @brief Constructor for Vrtbin.
         * @param vrtbinPath The path to the VRTBIN file.
         * @param bdf The Bus:Device.Function identifier.
         */
        Vrtbin(std::string vrtbinPath, const std::string& bdf);

        /**
         * @brief Extracts the VRTBIN file.
         */
        void extract();

        /**
         * @brief Gets the path to the system map file.
         * @return The path to the system map file.
         */
        std::string getSystemMapPath();

        /**
         * @brief Gets the path to the PDI file.
         * @return The path to the PDI file.
         */
        std::string getPdiPath();

        /**
         * @brief Gets the UUID of the VRTBIN.
         * @return The UUID of the VRTBIN.
         */
        std::string getUUID();

        /**
         * @brief Extracts the UUID from the VRTBIN file.
         */
        void extractUUID();

    };

} // namespace vrt

#endif // VRTBIN_HPP