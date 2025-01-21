#ifndef QDMA_INTF_HPP
#define QDMA_INTF_HPP

#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <errno.h>
#include <sys/types.h>
#include <string>

#define RW_MAX_SIZE 0x7ffff000 ///< Maximum size for read/write operations
#define GB_DIV 1000000000 ///< Divider for gigabytes
#define MB_DIV 1000000 ///< Divider for megabytes
#define KB_DIV 1000 ///< Divider for kilobytes
#define NSEC_DIV 1000000000 ///< Divider for nanoseconds
#define QMAX_PATH "/sys/bus/pci/devices/0000:%s:00.1/qdma/qmax" ///< Path for QMAX
#define QDMA_QUEUE_NAME "qdma%s001" ///< Format for QDMA queue name
#define QDMA_DEFAULT_QUEUE "/dev/qdma%s001-MM-0" ///< Default QDMA queue

namespace vrt {
    /**
     * @brief Class for interfacing with QDMA.
     */
    class QdmaIntf {
        static uint8_t queueIdx; ///< Queue index
        std::string bdf; ///< Bus:Device.Function identifier
        std::string queueName; ///< Queue name
        static bool queueExists; ///< Flag indicating if the queue exists

        /**
         * @brief Writes data from a buffer to a device.
         * @param dev The device to write to.
         * @param buffer The buffer to write from.
         * @param size The size of the buffer.
         * @param base The base address to write to.
         * @return The number of bytes written.
         */
        ssize_t write_from_buffer(const char* dev, char* buffer, uint64_t size, uint64_t base);

        /**
         * @brief Reads data from a file into a buffer.
         * @param fname The file to read from.
         * @param buffer The buffer to read into.
         * @param size The size of the buffer.
         * @param base The base address to read from.
         * @return The number of bytes read.
         */
        ssize_t read_to_buffer(const char *fname, char *buffer, uint64_t size, uint64_t base);

        /**
         * @brief Strips the bus part from the BDF.
         * @param bdf The BDF to strip.
         * @return The stripped bus part.
         */
        char* strip(const char* bdf);

        /**
         * @brief Creates a QDMA queue.
         * @param bdf The BDF of the device.
         * @return The name of the created queue.
         */
        char* create_qdma_queue(const char* bdf);

        /**
         * @brief Deletes a QDMA queue.
         * @param bdf The BDF of the device.
         * @return 0 on success, -1 on failure.
         */
        int delete_qdma_queue(const char* bdf);

        /**
         * @brief Private constructor to prevent direct instantiation.
         * @param bdf The BDF (Bus:Device.Function) of the device.
         */
        QdmaIntf(const std::string& bdf);

        /**
         * @brief Private constructor to prevent direct instantiation.
         */
        QdmaIntf();

        // Static instance pointer
        static QdmaIntf* instance;

    public:
        // Delete copy constructor and assignment operator
        QdmaIntf(const QdmaIntf&) = delete;
        QdmaIntf& operator=(const QdmaIntf&) = delete;

        /**
         * @brief Gets the singleton instance of the QdmaIntf.
         * @param bdf The BDF (Bus:Device.Function) of the device.
         * @return The singleton instance of the QdmaIntf.
         */
        static QdmaIntf& getInstance(const std::string& bdf);

        /**
         * @brief Gets the singleton instance of the QdmaIntf.
         * @return The singleton instance of the QdmaIntf.
         */
        static QdmaIntf& getInstance();

        /**
         * @brief Writes a buffer to the device.
         * @param buffer The buffer to write.
         * @param start_addr The starting address to write to.
         * @param size The size of the buffer.
         */
        void write_buff(char* buffer, uint64_t start_addr, uint64_t size);

        /**
         * @brief Reads a buffer from the device.
         * @param buffer The buffer to read into.
         * @param start_addr The starting address to read from.
         * @param size The size of the buffer.
         */
        void read_buff(char* buffer, uint64_t start_addr, uint64_t size);

        /**
         * @brief Destructor for QdmaIntf.
         */
        ~QdmaIntf();
    };

} // namespace vrt
#endif // QDMA_INTF_HPP