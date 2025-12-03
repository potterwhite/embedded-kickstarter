# CMakeLists.txt

cmake_minimum_required(VERSION 3.16)

# I. Config PROJECT_NAME And C++ Standards
set(PROJECT_NAME "executableTemplate")
project(${PROJECT_NAME} CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON) # Usually required

# II. Trace Top-level Directory
set(TOP_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(SRC_DIR "${TOP_DIR}/src")
set(INCLUDE_DIR "${TOP_DIR}/include")

# III. Set build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
    # set(CMAKE_BUILD_TYPE "Release")
    message(STATUS "No build type specified, defaulting to 'Debug'")
endif()
add_definitions(-DBUILD_TYPE="${CMAKE_BUILD_TYPE}")


#############################################################
# IV. Compile options Sets global compilation flags
set(BASIC_COMPILE_OPTIONS -Wall -Wextra -Werror)

# advanced & most serious harsh options let no mistakes go
set(STRINGENT_COMPILE_OPTIONS
    -Wconversion
    -Wsign-conversion
    -Wfloat-conversion
    -Wpedantic
    -Wcast-qual
    -Wcast-align
    -Wunused
    -Woverloaded-virtual
    -Wformat=2
    -Wformat-security
    -Wformat-nonliteral
    -Wuninitialized
    -Winit-self
    -Wswitch-enum
    -Wswitch-default
    -Wmissing-include-dirs
    -Wredundant-decls
    -Wshadow
    -Wundef
    -Wdouble-promotion)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Debug: No optimization, with debug info
    add_compile_options(-Og -g -DDEBUG ${STRINGENT_COMPILE_OPTIONS})
elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    # RelWithDebInfo: Full optimization with debug info
    add_compile_options(-O2 -g -DNDEBUG ${STRINGENT_COMPILE_OPTIONS})
elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    # MinSizeRel: Size optimization
    add_compile_options(-Os -DNDEBUG ${STRINGENT_COMPILE_OPTIONS})
    # add_link_options(-s)
else() # Release
    # Release: Full optimization, no debug info
    add_compile_options(-O3 -DNDEBUG ${STRINGENT_COMPILE_OPTIONS})
    # add_link_options(-s)
endif()

########################### End of Section V ##################################

# V. Set RPATH (Crucial! Allows the executable to find .so files when running on the ARM board).
# $ORIGIN represents the directory where the executable is located.
# This means you need to place all dependent lib*.so files and the compiled
# bin (executable) in the [same directory] on the ARM board.
set(CMAKE_INSTALL_RPATH "$ORIGIN")
# Apply RPATH during the build as well, so you can see the effect when testing
# in the build directory on the PC (if the architecture matches) or checking RPATH.
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)


# ##################################################################################################
# VI. Dependency Management
# Define all libraries required by your project here.
# This way src/CMakeLists.txt does not need to know the specific dependencies.
# For a clean template, we leave it empty for now. Future Helmsman projects will add OpenCV etc. here.
set(COMMON_LIBRARIES "") # Example: "OpenCV::opencv" "Threads::Threads"
# ##################################################################################################


# VII. Add Subdirectories
add_subdirectory(${SRC_DIR})

option(BUILD_TEST "Build the tests for the project" OFF)
if(BUILD_TEST STREQUAL "TRUE")
    # enable_testing()
    add_subdirectory(test)
endif()