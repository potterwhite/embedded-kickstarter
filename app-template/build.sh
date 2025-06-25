#!/bin/bash

1_0_load_env() {
    set -e
    MAKE_VERBOSE_OPTION=""
    if [ "$V" != "" ]; then
        set -x
        MAKE_VERBOSE_OPTION="VERBOSE=1"
    fi

    REVISION_CODE="v1.0.0"
    BASH_SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]})"
    BASH_SCRIPT_DIR="$(dirname ${BASH_SCRIPT_PATH})"
    BUILD_TOP_DIR="${BASH_SCRIPT_DIR}/build"
    INSTALL_TOP_DIR="${BASH_SCRIPT_DIR}/install"
    INSTALL_INC_DIR="${INSTALL_TOP_DIR}/include"
    INSTALL_BIN_DIR="${INSTALL_TOP_DIR}/bin"

    # 5. sysroot places
    SDK_HOST_PREFIX="/development/docker_volumes/src/sdk/rk3588s-linux/buildroot/output/rockchip_rk3588/host"
    CMAKE_SYSROOT="${SDK_HOST_PREFIX}/aarch64-buildroot-linux-gnu/sysroot"

    SRC_TOP_DIR="${BASH_SCRIPT_DIR}/src"

    ARGC="0"
    ARGC_2ND_OPTION=""
    MACRO_OPTION_1_CLEAN="clean"
    MACRO_OPTION_2_BUILD="build"
    MACRO_OPTION_3_BUILD_AFTER_CLEAN="cb"
    MACRO_OPTION_4_INSTALL="install"
    MACRO_OPTION_5_TEST="test"
}

1_1_arguments_validation() {
    if [ "$#" == "0" ]; then
        ARGC=1
    elif [ "$#" == "1" ]; then
        ARGC=2

        if [ "$1" = "${MACRO_OPTION_1_CLEAN}" ] ||
            [ "$1" = "${MACRO_OPTION_2_BUILD}" ] ||
            [ "$1" = "${MACRO_OPTION_3_BUILD_AFTER_CLEAN}" ] ||
            [ "$1" = "${MACRO_OPTION_4_INSTALL}" ] ||
            [ "$1" = "${MACRO_OPTION_5_TEST}" ]; then
            ARGC_2ND_OPTION=${1}
        else
            1_2_helper_print
            exit 1
        fi
    else
        1_2_helper_print
        exit 1
    fi
}

1_2_helper_print() {
    echo
    echo "./build.sh clean"
    echo "./build.sh build"
    echo "./build.sh test"
    echo "./build.sh cb(clean and build)"
    echo "no other options"
    echo
}

2_1_preparation() {
    mkdir -p ${BUILD_TOP_DIR}
    echo "mkdir -p ${BUILD_TOP_DIR}"
    mkdir -p ${INSTALL_INC_DIR}
    echo "mkdir -p ${INSTALL_INC_DIR}"
    mkdir -p ${INSTALL_BIN_DIR}
    echo "mkdir -p ${INSTALL_BIN_DIR}"
}

2_2_clean_all() {
    rm -rf ${BUILD_TOP_DIR}
    echo "Removed ${BUILD_TOP_DIR}"
    rm -rf ${INSTALL_TOP_DIR}
    echo "Removed ${INSTALL_TOP_DIR}"
}

2_3_cmake_generate_makefile() {
    cmake \
        -S ${BASH_SCRIPT_DIR} \
        -B ${BUILD_TOP_DIR} \
        "-DCMAKE_INSTALL_PREFIX=${INSTALL_TOP_DIR}"
}

2_4_make_execution() {
    make -C ${BUILD_TOP_DIR} ${MAKE_VERBOSE_OPTION}
}

2_6_install_target() {
    cmake --install ${BUILD_TOP_DIR}

    # 2_5_copy_dependencies

    # rsync -av --progress ${SRC_TOP_DIR}/* ${INSTALL_INC_DIR}
    # echo "Installed headers to ${INSTALL_INC_DIR}"

    # rsync -av --progress ${BUILD_TOP_DIR}/${FINAL_BIN_NAME} ${INSTALL_BIN_DIR}
    # echo "Installed library to ${INSTALL_BIN_DIR}"

    # rm -rf ${INSTALL_PLACE_2ND_DIR}

    # rsync -av --progress ${INSTALL_TOP_DIR}/* ${INSTALL_PLACE_2ND_DIR}
    # echo "Installed whole install dir to ${INSTALL_PLACE_2ND_DIR}"

    echo
    echo "Installation completed successfully."
}

2_7_make_test() {
    # 确保构建目录存在
    2_1_preparation

    # 生成 CMake 构建文件，启用 BUILD_TEST
    cmake \
        -S ${BASH_SCRIPT_DIR} \
        -B ${BUILD_TOP_DIR} \
        "-DCMAKE_INSTALL_PREFIX=${INSTALL_TOP_DIR}" \
        "-DBUILD_TEST=TRUE"

    # 仅构建测试目标（假设 test/CMakeLists.txt 定义了目标，例如 'test_main'）
    make -C ${BUILD_TOP_DIR}/test ${MAKE_VERBOSE_OPTION}

    echo "测试构建完成。"
}

3_0_exec_as_requirement() {
    if [ $ARGC == "1" ]; then
        1_2_helper_print
        return
    fi

    if [ $ARGC == "2" ]; then
        if [ $ARGC_2ND_OPTION == ${MACRO_OPTION_1_CLEAN} ]; then
            2_2_clean_all
            2_1_preparation
        elif [ $ARGC_2ND_OPTION == ${MACRO_OPTION_2_BUILD} ]; then
            2_3_cmake_generate_makefile
            2_4_make_execution
        elif [ $ARGC_2ND_OPTION == ${MACRO_OPTION_3_BUILD_AFTER_CLEAN} ]; then
            2_2_clean_all
            2_1_preparation
            2_3_cmake_generate_makefile
            2_4_make_execution
            2_6_install_target
        elif [ $ARGC_2ND_OPTION == ${MACRO_OPTION_4_INSTALL} ]; then
            2_6_install_target
        elif [ $ARGC_2ND_OPTION == ${MACRO_OPTION_5_TEST} ]; then
            2_7_make_test
            2_6_install_target
        fi
    fi
}

main() {
    1_0_load_env
    1_1_arguments_validation "$@"

    3_0_exec_as_requirement
}

main "$@"
