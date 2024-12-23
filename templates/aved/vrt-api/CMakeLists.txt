cmake_minimum_required(VERSION 3.10)
project(vrt-api)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${CMAKE_SOURCE_DIR}/include/ ${CMAKE_SOURCE_DIR}/src/ /usr/include/ami/ /usr/include/libxml2)

# Define sources for the library
file(GLOB LIB_SOURCES ${CMAKE_SOURCE_DIR}/src/allocator/*.cpp ${CMAKE_SOURCE_DIR}/include/buffer/*.hpp
${CMAKE_SOURCE_DIR}/src/qdma/*.cpp ${CMAKE_SOURCE_DIR}/src/api/*.cpp 
${CMAKE_SOURCE_DIR}/src/parser/*.cpp ${CMAKE_SOURCE_DIR}/src/register/*.cpp ${CMAKE_SOURCE_DIR}/src/driver/*.cpp)

# Create the shared library
add_library(vrt SHARED ${LIB_SOURCES})

# Specify the output directory for the shared library
set_target_properties(vrt PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Define sources for the executable
#file(GLOB EXE_SOURCES ${CMAKE_SOURCE_DIR}/src/main.cpp)

# Link the library to the executable
# target_link_libraries(${PROJECT_NAME} vrt ami xml2)