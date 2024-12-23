#ifndef BUFFER_HPP
#define BUFFER_HPP

#include "allocator/allocator.hpp"
#include "qdma/qdma_intf.hpp"

namespace vrt {

    /**
     * @brief Enum class representing the type of synchronization.
     */
    enum class SyncType {
        HOST_TO_DEVICE, ///< Synchronize from host to device
        DEVICE_TO_HOST, ///< Synchronize from device to host
    };

    /**
     * @brief Class representing a buffer.
     * @tparam T The type of elements in the buffer.
     */
    template <typename T>
    class Buffer {
    public:
        /**
         * @brief Constructor for Buffer.
         * @param size The size of the buffer.
         * @param type The type of memory range.
         */
        Buffer(size_t size, MemoryRangeType type);

        /**
         * @brief Destructor for Buffer.
         */
        ~Buffer();

        /**
         * @brief Gets a pointer to the buffer.
         * @return A pointer to the buffer.
         */
        T* get() const;

        /**
         * @brief Overloads the subscript operator to access buffer elements.
         * @param index The index of the element to access.
         * @return A reference to the element at the specified index.
         */
        T& operator[](size_t index);

        /**
         * @brief Overloads the subscript operator to access buffer elements (const version).
         * @param index The index of the element to access.
         * @return A const reference to the element at the specified index.
         */
        const T& operator[](size_t index) const;

        /**
         * @brief Gets the physical address of the buffer.
         * @return The physical address of the buffer.
         */
        uint64_t getPhysAddr() const;

        /**
         * @brief Gets the lower 32 bits of the physical address of the buffer.
         * @return The lower 32 bits of the physical address of the buffer.
         */
        uint32_t getPhysAddrLow() const;

        /**
         * @brief Gets the upper 32 bits of the physical address of the buffer.
         * @return The upper 32 bits of the physical address of the buffer.
         */
        uint32_t getPhysAddrHigh() const;

        /**
         * @brief Synchronizes the buffer.
         * @param syncType The type of synchronization.
         */
        void sync(SyncType syncType);

    private:
        /**
         * @brief Initializes the memory ranges.
         */
        static void initializeMemoryRanges();

        uint64_t startAddress; ///< The starting address of the buffer
        T* localBuffer; ///< Pointer to the local buffer
        size_t size; ///< The size of the buffer
        MemoryRangeType type; ///< The type of memory range
    };

} // namespace vrt

#include "api/buffer.tpp"

#endif // BUFFER_HPP