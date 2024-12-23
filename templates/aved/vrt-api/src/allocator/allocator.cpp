#include "allocator/allocator.hpp"

namespace vrt {
    Superblock::Superblock(uint64_t startAddress, uint64_t size)
        : startAddress(startAddress), size(size), offset(0) {}

    uint64_t Superblock::allocate(uint64_t size) {
        if (!freeList.empty()) {
            uint64_t addr = freeList.back();
            freeList.pop_back();
            return addr;
        }
        if (offset + size > this->size) {
            throw std::bad_alloc();
        }
        uint64_t addr = startAddress + offset;
        offset += size;
        return addr;
    }

    void Superblock::deallocate(uint64_t addr) {
        freeList.push_back(addr);
    }

    MemoryRange::MemoryRange(uint64_t startAddress, uint64_t size)
        : startAddress(startAddress), size(size), offset(0) {}

    Allocator& Allocator::getInstance(uint64_t superblockSize) {
        static Allocator instance(superblockSize);
        return instance;
    }

    Allocator::Allocator(uint64_t superblockSize)
        : superblockSize(superblockSize) {}

    void Allocator::addMemoryRange(MemoryRangeType type, uint64_t startAddress, uint64_t size) {
        memoryRanges.emplace(type, MemoryRange(startAddress, size));
    }

    uint64_t Allocator::allocate(uint64_t size, MemoryRangeType type) {
        auto it = memoryRanges.find(type);
        if (it == memoryRanges.end()) {
            throw std::out_of_range("Invalid memory range type");
        }

        MemoryRange& range = it->second;

        if (size < superblockSize / 2) {
            for (auto& superblock : range.superblocks) {
                try {
                    uint64_t addr = superblock.allocate(size);
                    addrToSuperblock[addr] = &superblock;
                    return addr;
                } catch (const std::bad_alloc&) {
                    continue;
                }
            }
            if (range.offset + superblockSize > range.size) {
                throw std::bad_alloc();
            }
            range.superblocks.emplace_back(range.startAddress + range.offset, superblockSize);
            range.offset += superblockSize;
            uint64_t addr = range.superblocks.back().allocate(size);
            addrToSuperblock[addr] = &range.superblocks.back();
            return addr;
        } else {
            if (!range.freeList.empty()) {
                uint64_t addr = range.freeList.back();
                range.freeList.pop_back();
                return addr;
            }
            if (range.offset + size > range.size) {
                throw std::bad_alloc();
            }
            uint64_t addr = range.startAddress + range.offset;
            range.offset += size;
            return addr;
        }
    }

    void Allocator::deallocate(uint64_t addr) {
        auto it = addrToSuperblock.find(addr);
        if (it != addrToSuperblock.end()) {
            it->second->deallocate(addr);
            addrToSuperblock.erase(it);
        } else {
            for (auto& [type, range] : memoryRanges) {
                if (addr >= range.startAddress && addr < range.startAddress + range.size) {
                    range.freeList.push_back(addr);
                    return;
                }
            }
        }
    }

    uint64_t Allocator::getSize(MemoryRangeType type) const {
        auto it = memoryRanges.find(type);
        if (it == memoryRanges.end()) {
            throw std::out_of_range("Invalid memory range type");
        }
        return it->second.size;
    }
}