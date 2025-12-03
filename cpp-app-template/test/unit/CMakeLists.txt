# test/unit/CMakeLists.txt
# *********************************************************************************************

# Define module directory name
set(MODULE_DIR "app-bin")

file(GLOB TEST_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/test-bin.cpp"
)

# sources
# We need to compile the business logic implementation file processor_logic.cpp
# Note: This should only include .cpp files; .h files are handled automatically by the compiler
file(GLOB MODULE_SOURCES
    # "${CMAKE_CURRENT_SOURCE_DIR}/processor_logic.cpp"
)

set(INCLUDE_DIRS
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${INCLUDE_DIR}"
)

set(LINK_LIBS

)

set(LINK_DIRS

)

set(PCH_FILES

)

add_unit_test(
    NAME "${BIN_PREFIX}_${MODULE_DIR}"
    TEST_SOURCES "${TEST_SOURCES}"
    MODULE_SOURCES "${MODULE_SOURCES}"
    INCLUDE_DIRS "${INCLUDE_DIRS}"
    LINK_LIBS "${LINK_LIBS}"
    LINK_DIRS "${LINK_DIRS}"
    PCH_FILES ${PCH_FILES}
    MODULE_DIR "${MODULE_DIR}"
)