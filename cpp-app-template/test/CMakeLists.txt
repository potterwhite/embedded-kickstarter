# test/CMakeLists.txt

# GTest Configuration
set(GTEST_ROOT ${CMAKE_SYSROOT}/usr
        CACHE PATH "GTest root directory"
)
set(GTEST_INCLUDE_DIR "${GTEST_ROOT}/include"
        # ${SRC_DIR}
        CACHE PATH "GTest include directory"
)

# libgtest_main must be put before libgtest
set(GTEST_LIBRARY ${GTEST_ROOT}/lib/libgtest.a
        CACHE PATH "GTest library")
set(GTEST_MAIN_LIBRARY ${GTEST_ROOT}/lib/libgtest_main.a
        CACHE PATH "GTest main library")

# --- GMock (New section) ---
set(GMOCK_LIBRARY ${GTEST_ROOT}/lib/libgmock.a
        CACHE PATH "GMock library")
set(GMOCK_MAIN_LIBRARY ${GTEST_ROOT}/lib/libgmock_main.a
        CACHE PATH "GMock main library") # gmock_main usually includes gtest_main, but explicit linking is safer

# ========================================================
# Define a more modular function to create test targets
function(add_unit_test)
        # Define supported named arguments
        set(options "")
        set(oneValueArgs NAME MODULE_DIR)
        set(multiValueArgs TEST_SOURCES MODULE_SOURCES INCLUDE_DIRS LINK_LIBS LINK_DIRS PCH_FILES)

        # ---------------------------------------------------------
        # a. Parse named arguments
        cmake_parse_arguments(TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

        # ---------------------------------------------------------
        # b. Verify necessary arguments
        if(NOT DEFINED TEST_NAME)
                message(FATAL_ERROR "NAME argument must be provided")
        endif()
        # ---------------------------------------------------------

        # *********************************************************
        # i. Set target name
        set(TARGET_NAME ${TEST_NAME})

        # *********************************************************
        # ii. Set default values
        if(NOT DEFINED TEST_MODULE_DIR)
                set(TEST_MODULE_DIR "tests")
        endif()

        # *********************************************************
        # iii. Create test executable
        add_executable(${TARGET_NAME}
                ${TEST_TEST_SOURCES}
                ${TEST_MODULE_SOURCES}
        )

        # *********************************************************
        # iv. Add precompiled headers based on module specific requirements
        if(TEST_PCH_FILES)
                target_precompile_headers(${TARGET_NAME} PUBLIC ${TEST_PCH_FILES})
        elseif(EXISTS "${TOP_DIR}/src/pch.h")
                # Only add basic PCH file to avoid unnecessary dependencies
                target_precompile_headers(${TARGET_NAME} PUBLIC "${TOP_DIR}/src/pch.h")
        endif()

        # *********************************************************
        # v. Link dependency libraries (always required)
        # target_link_libraries(${TARGET_NAME} PUBLIC
        #         ${GTEST_LIBRARY}
        #         ${GTEST_MAIN_LIBRARY}
        #         ${GMOCK_LIBRARY}
        #         ${GMOCK_MAIN_LIBRARY}
        #         ${MODULE_NAME_COMMON}
        # )

        target_link_libraries(${TARGET_NAME} PUBLIC
                # gmock_main calls functions from gmock and gtest
                ${GMOCK_MAIN_LIBRARY}
                # gmock calls functions from gtest
                ${GMOCK_LIBRARY}
                # gtest_main calls functions from gtest
                ${GTEST_MAIN_LIBRARY}
                # gtest is the core implementation, depended on by others, so put it last
                ${GTEST_LIBRARY}
                # ${MODULE_NAME_COMMON} # This variable seems undefined, commented out for now
        )

        # Add extra link libraries
        if(TEST_LINK_LIBS)
                target_link_libraries(${TARGET_NAME} PUBLIC ${TEST_LINK_LIBS})
        endif()

        if(TEST_LINK_DIRS)
                target_link_directories(${TARGET_NAME} PUBLIC
                        ${TEST_LINK_DIRS}
                )
        endif()

        # *********************************************************
        # vi. Include directories
        target_include_directories(${TARGET_NAME} PRIVATE
                ${GTEST_INCLUDE_DIR}
        )

        # Add extra include directories
        if(TEST_INCLUDE_DIRS)
                target_include_directories(${TARGET_NAME} PRIVATE
                        ${TEST_INCLUDE_DIRS}
                )
        endif()

        # *********************************************************
        # vii. Install by module category
        install(TARGETS ${TARGET_NAME}
                RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/${TEST_MODULE_DIR})

        # *********************************************************
        # viii. Set runtime output directory
        set_target_properties(
                ${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY
                "${CMAKE_INSTALL_PREFIX}/bin/${TEST_MODULE_DIR}")

        # *********************************************************
        # ix. Add to CTest
        add_test(NAME ${TARGET_NAME} COMMAND ${TARGET_NAME})
endfunction()

# *********************************************************************************************

add_subdirectory(unit)
# add_subdirectory(integration)

# enabling test is only one time execution
enable_testing()