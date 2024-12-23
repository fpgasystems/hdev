#ifndef CUSTOM_ALLOCATOR_HPP
#define CUSTOM_ALLOCATOR_HPP

#include <unordered_map>
#include <vector>
#include <stdexcept>
#include <cstdint>

namespace vrt {

    /**
     * @brief Enum class representing the type of memory range.
     */
    enum class MemoryRangeType {
        HBM, ///< High Bandwidth Memory
        DDR  ///< Double Data Rate Memory
    };

    /// Starting address of HBM
    constexpr uint64_t HBM_START = 0x4000000000;
    /// Size of HBM (32 GB)
    constexpr uint64_t HBM_SIZE = 32L * 1024 * 1024 * 1024; // 32G

    /// Starting address of DDR
    constexpr uint64_t DDR_START = 0x50080000000;
    /// Size of DDR (32 GB)
    constexpr uint64_t DDR_SIZE = 32L * 1024 * 1024 * 1024; // 32G

    /**
     * @brief Class representing a superblock of memory.
     */
    class Superblock {
    public:
        /**
         * @brief Constructor for Superblock.
         * @param startAddress The starting address of the superblock.
         * @param size The size of the superblock.
         */
        Superblock(uint64_t startAddress, uint64_t size);

        /**
         * @brief Allocates a block of memory from the superblock.
         * @param size The size of the memory block to allocate.
         * @return The starting address of the allocated memory block.
         */
        uint64_t allocate(uint64_t size);

        /**
         * @brief Deallocates a block of memory.
         * @param addr The starting address of the memory block to deallocate.
         */
        void deallocate(uint64_t addr);

    private:
        uint64_t startAddress; ///< The starting address of the superblock.
        uint64_t size; ///< The size of the superblock.
        uint64_t offset; ///< The current offset for allocation.
        std::vector<uint64_t> freeList; ///< List of free memory blocks.
    };

    /**
     * @brief Struct representing a range of memory.
     */
    struct MemoryRange {
        uint64_t startAddress; ///< The starting address of the memory range.
        uint64_t size; ///< The size of the memory range.
        uint64_t offset; ///< The current offset for allocation.
        std::vector<Superblock> superblocks; ///< List of superblocks in the memory range.
        std::vector<uint64_t> freeList; ///< List of free memory blocks.

        /**
         * @brief Constructor for MemoryRange.
         * @param startAddress The starting address of the memory range.
         * @param size The size of the memory range.
         */
        MemoryRange(uint64_t startAddress, uint64_t size);
    };

    /**
     * @brief Class representing a memory allocator.
     */
    class Allocator {
    public:
        /**
         * @brief Gets the singleton instance of the Allocator.
         * @param superblockSize The size of the superblocks to use.
         * @return The singleton instance of the Allocator.
         */
        static Allocator& getInstance(uint64_t superblockSize = 0x1000);

        /**
         * @brief Adds a memory range to the allocator.
         * @param type The type of memory range (HBM or DDR).
         * @param startAddress The starting address of the memory range.
         * @param size The size of the memory range.
         */
        void addMemoryRange(MemoryRangeType type, uint64_t startAddress, uint64_t size);

        /**
         * @brief Allocates a block of memory.
         * @param size The size of the memory block to allocate.
         * @param type The type of memory range to allocate from (HBM or DDR).
         * @return The starting address of the allocated memory block.
         */
        uint64_t allocate(uint64_t size, MemoryRangeType type);

        /**
         * @brief Deallocates a block of memory.
         * @param addr The starting address of the memory block to deallocate.
         */
        void deallocate(uint64_t addr);

        /**
         * @brief Gets the size of the specified memory range type.
         * @param type The type of memory range (HBM or DDR).
         * @return The size of the specified memory range type.
         */
        uint64_t getSize(MemoryRangeType type) const;

    private:
        /**
         * @brief Private constructor for Allocator.
         * @param superblockSize The size of the superblocks to use.
         */
        Allocator(uint64_t superblockSize);

        // Delete copy constructor and assignment operator
        Allocator(const Allocator&) = delete;
        Allocator& operator=(const Allocator&) = delete;

        uint64_t superblockSize; ///< The size of the superblocks.
        std::unordered_map<MemoryRangeType, MemoryRange> memoryRanges; ///< Map of memory ranges by type.
        std::unordered_map<uint64_t, Superblock*> addrToSuperblock; ///< Map of addresses to superblocks.
    };

} // namespace vrt

#endif // CUSTOM_ALLOCATOR_HPP