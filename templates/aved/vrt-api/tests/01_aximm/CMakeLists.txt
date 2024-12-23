cmake_minimum_required(VERSION 3.10)
project(aximm_example)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/../../include 
                    ${CMAKE_SOURCE_DIR}/../../include/parser
                    ${CMAKE_SOURCE_DIR}/../../include/api
                    ${CMAKE_SOURCE_DIR}/../../src 
                    /usr/include/ami
                    /usr/include/libxml2)

# Define sources for the executable
set(EXE_SOURCES 01_example.cpp)

# Create the executable
add_executable(${PROJECT_NAME} ${EXE_SOURCES})

# Link the library to the executable
target_link_libraries(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/../../build/lib/libvrt.so /home/aulmamei/vrt-api/tests/01_aximm/build/v80-vitis-flow/build/aved-fork/sw/AMI/api/build/libami.a xml2)
