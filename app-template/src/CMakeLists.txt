set(BIN_NAME "${PROJECT_NAME}.bin")
add_executable(${BIN_NAME} main.cpp)
target_compile_definitions(${BIN_NAME} PRIVATE
    PROJECT_NAME="${PROJECT_NAME}"
)

# II. 指定头文件搜索路径
target_include_directories(
    ${BIN_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${INCLUDE_DIR}
)

# III. 指定链接库的搜索路径 (编译时用)
target_link_directories(${BIN_NAME} PRIVATE

)

# IV. 链接需要的库
target_link_libraries(${BIN_NAME} PRIVATE

)

# V. install rules
install(
    TARGETS ${BIN_NAME}
    DESTINATION bin
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

# VI. customized cmds
if(CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    # 获取 strip 工具的路径 CMAKE_STRIP 是 CMake 通常能找到的 strip 工具，但交叉编译时可能需要指定 find_program(CROSS_STRIP NAMES
    # ${CMAKE_C_COMPILER_TARGET}-strip aarch64-linux-gnu-strip aarch64-none-linux-gnu-strip)
    set(CROSS_STRIP ${TOOLCHAIN_BIN_DIR}/aarch64-buildroot-linux-gnu-strip) # 直接使用你的工具链中的 strip

    if(CROSS_STRIP)
        add_custom_command(
            TARGET ${BIN_NAME}
            POST_BUILD
            COMMAND ${CROSS_STRIP} ${BIN_NAME}
            COMMENT "Stripping ${BIN_NAME}"
            COMMAND ls -lha ${BIN_NAME}
            COMMAND file ${BIN_NAME})
    else()
        message(WARNING "Strip command not found. Executable will not be stripped automatically.")
    endif()
endif()

