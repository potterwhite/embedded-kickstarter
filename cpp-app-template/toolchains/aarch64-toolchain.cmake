# *********************************************************
# toolchains/aarch64-toolchain.cmake
#
# This toolchain file configures CMake for cross-compiling
# to an aarch64 Linux target using a Buildroot SDK.
# *********************************************************

# =========================================================
# I. Set Target System Information
# =========================================================
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# =========================================================
# II. Set Sysroot (System Root)
# This is the root directory of the cross-compilation environment;
# all headers and libraries will be searched here.
# =========================================================
set(SDK_HOST_PREFIX "/development/docker_volumes/src/sdk/rk3588s-linux/buildroot/output/rockchip_rk3588/host")
set(CMAKE_SYSROOT ${SDK_HOST_PREFIX}/aarch64-buildroot-linux-gnu/sysroot)

# =========================================================
# III. Set Cross Compilers
# =========================================================
set(TOOLCHAIN_BIN_DIR "${SDK_HOST_PREFIX}/bin")
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-g++)

# =========================================================
# IV. Search Path Configuration
# Instruct CMake to search for libraries, headers, and packages only within the Sysroot.
# =========================================================
set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# =========================================================
# V. RPATH Settings (Optional, but recommended here)
# Allow the executable to find .so files located in the same directory on the target board.
# =========================================================
set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# =========================================================
# VI. Set other toolchain utilities
# Explicitly specifying these tools prevents CMake from mistakenly finding the host versions.
# =========================================================
set(CMAKE_STRIP ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-strip)
set(CMAKE_AR ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-ar)
set(CMAKE_LINKER ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-ld)
set(CMAKE_NM ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-nm)
set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-objcopy)
set(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-objdump)
set(CMAKE_RANLIB ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-ranlib)

# =========================================================
# VII. Pkg-Config Cross-Compilation Setup
# =========================================================

# 1. Clear the default path to avoid picking up host (PC) libraries
set(ENV{PKG_CONFIG_DIR} "")

# 2. Force pkg-config to look ONLY inside the Target Sysroot
# Note: We use the ${CMAKE_SYSROOT} variable defined earlier in this file
set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")

# 3. Define the sysroot for pkg-config so it prepends the correct path to -I and -L flags
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")

# 4. (Optional but recommended) If your SDK provides a cross-pkg-config wrapper, use it.
# Usually located in the same bin directory as gcc.
# If this file exists, uncomment the line below:
# set(PKG_CONFIG_EXECUTABLE "${SDK_HOST_PREFIX}/bin/pkg-config")
