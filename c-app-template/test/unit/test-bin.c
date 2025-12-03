// test/unit/test-bin.c (or whichever file contained this logic)

// ... other includes ...
#include <stdio.h>
#include <string.h>    // Required for strcmp
#include <stdbool.h>   // Required for bool, true, false
#include "main-utils.h"  // Include header file

// Ensure BUILD_TYPE has a default if not defined by CMake
#ifndef BUILD_TYPE
#define BUILD_TYPE "Debug"
#endif

// ... kcurrent_app_name, SignalHandler code remains unchanged ...

// Function Definitions

bool isDebug(void) {
    // In C, we cannot compare strings with ==. We must use strcmp.
    // strcmp returns 0 if strings are equal.
    return (strcmp(BUILD_TYPE, "Debug") == 0);
}

bool isRelease(void) {
    return (strcmp(BUILD_TYPE, "Release") == 0);
}

int main(void) {
    printf("Running C Unit Tests...\n");

    if (isDebug()) {
        printf("[PASS] Build type is Debug\n");
    } else {
        printf("[INFO] Build type is NOT Debug (Current: %s)\n", BUILD_TYPE);
    }

    // 这里可以写你简单的测试逻辑
    // 如果是纯C且不想引入第三方库，可以用 assert
    // #include <assert.h>
    // assert(isDebug() == true);

    printf("All tests finished.\n");
    return 0;
}