# CMakeLists.txt

cmake_minimum_required(VERSION 3.16)

# I. 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON) # 通常需要

# II. 追溯顶层目录
set(TOP_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(SRC_DIR "${TOP_DIR}/src")
set(INCLUDE_DIR "${TOP_DIR}/include")

# ##################################################################################################
# III. 设置system information
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# IV. 设置sysroot
set(SDK_HOST_PREFIX
    "/development/docker_volumes/src/sdk/rk3588s-linux/buildroot/output/rockchip_rk3588/host")
set(CMAKE_SYSROOT ${SDK_HOST_PREFIX}/aarch64-buildroot-linux-gnu/sysroot)

# V. 设置toolchain路径
set(TOOLCHAIN_BIN_DIR "${SDK_HOST_PREFIX}/bin")

if(NOT CMAKE_C_COMPILER) # 只有在未被外部（如命令行）设置时才设置
    set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-gcc) # 确认编译器实际名称
endif()
if(NOT CMAKE_CXX_COMPILER) # 只有在未被外部（如命令行）设置时才设置
    set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-g++) # 确认编译器实际名称
endif()

# VI. 设置 CMake 在哪里查找头文件、库和程序
set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) # Don't look for programs in the sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY) # Only look for libraries in the sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY) # Only look for includes in the sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY) # Only look for CMake packages in the sysroot

# # VII. 设置project名称
set(PROJECT_NAME "executableTemplate")
project(${PROJECT_NAME} CXX)

# VIII. 设置build type
set(CMAKE_BUILD_TYPE "Debug")
# set(CMAKE_BUILD_TYPE "Release")
add_definitions(-DBUILD_TYPE="${CMAKE_BUILD_TYPE}")

# IX. Compile options Sets global compilation flags
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

# X. 设置 RPATH (关键！让可执行文件在ARM板上运行时能找到 .so 文件) $ORIGIN 表示可执行文件所在的目录。 这意味着你需要把所依赖的所有 lib*.so这些文件 和编译出来的
# bin(可执行文件)放在ARM板上的【同一个目录】下。
set(CMAKE_INSTALL_RPATH "$ORIGIN")
# 在构建时也应用 RPATH，这样你在PC上构建目录中测试（如果架构匹配）或检查RPATH时也能看到效果
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# ##################################################################################################
# XI. app-first
add_subdirectory(${SRC_DIR})

if(BUILD_TEST STREQUAL "TRUE")
    add_subdirectory(test)
endif()
