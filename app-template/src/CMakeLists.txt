
# I. Config Executable
set(BIN_NAME "${PROJECT_NAME}.bin")
add_executable(${BIN_NAME} main.cpp)

# II. Make ${PROJECT_NAME} share with src files
target_compile_definitions(${BIN_NAME} PRIVATE
    PROJECT_NAME="${PROJECT_NAME}"
)

# III. 指定头文件搜索路径
target_include_directories(${BIN_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${INCLUDE_DIR}
)

# IV. 链接公共库
# 直接链接在顶层CMakeLists.txt中定义的COMMON_LIBRARIES列表
target_link_libraries(${BIN_NAME} PRIVATE
    ${COMMON_LIBRARIES}
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
    if(CMAKE_STRIP)
        add_custom_command(
            TARGET ${BIN_NAME}
            POST_BUILD
            COMMAND ${CMAKE_STRIP} ${BIN_NAME}
            COMMENT "Stripping ${BIN_NAME}"
            COMMAND ls -lha ${BIN_NAME}
            COMMAND file ${BIN_NAME})
    else()
        message(WARNING "Strip command not found. Executable will not be stripped automatically.")
    endif()
endif()

