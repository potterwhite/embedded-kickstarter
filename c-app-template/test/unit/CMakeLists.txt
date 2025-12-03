# test/unit/CMakeLists.txt
# *********************************************************************************************

# 1. Define the name of the test executable
set(TEST_BIN_NAME "unit_test_bin")

# 2. Add the executable
# We use standard 'add_executable' instead of the custom 'add_unit_test' macro.
# This prevents CMake from trying to link C++ libraries like libgmock.
add_executable(${TEST_BIN_NAME}
    "${CMAKE_CURRENT_SOURCE_DIR}/test-bin.c"
    # If you need to test logic from src/, add the .c files here.
    # Example: "${SRC_DIR}/some_logic.c"
)

# 3. Setup Include Directories
# This allows test-bin.c to find "main-utils.h" in the include/ folder.
target_include_directories(${TEST_BIN_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${INCLUDE_DIR}"  # Defined in the top-level CMakeLists.txt
)

# 4. Pass Preprocessor Definitions
# Passes the build type string to the C code (for the isDebug/isRelease functions).
target_compile_definitions(${TEST_BIN_NAME} PRIVATE
    BUILD_TYPE="${CMAKE_BUILD_TYPE}"
)

# 5. Link Libraries
# For pure C, you might need the math library (m) or pthread.
# We do not link gmock or gtest here.
target_link_libraries(${TEST_BIN_NAME} PRIVATE
    # m         # Uncomment if you use math.h
    # pthread   # Uncomment if you use threads
)

# 6. Register Test
# This allows you to run the test using 'make test' or 'ctest'.
add_test(NAME ${TEST_BIN_NAME} COMMAND ${TEST_BIN_NAME})