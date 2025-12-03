#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <stdbool.h> // Introduced in C99, used for bool, true, false

// Assume PROJECT_NAME and BUILD_TYPE are defined by CMake
// To prevent IDE errors, optional default values can be added
#ifndef PROJECT_NAME
#define PROJECT_NAME "unknown_app"
#endif
#ifndef BUILD_TYPE
#define BUILD_TYPE "Debug"
#endif

// Corresponds to C++ constexpr std::string_view
const char* kcurrent_app_name = PROJECT_NAME;

// --- Globals used for signal handling ---
// In C, global variables modified in signal handlers should be declared as volatile sig_atomic_t.
// This ensures atomicity of reads/writes and prevents compiler optimization of variable reads.
static volatile sig_atomic_t g_stop_signal_received = 0;

// Added 'static' to fix -Wmissing-prototypes warning
static void SignalHandler(int signal_num) {
    g_stop_signal_received = 1;

    // Note: Strictly speaking, printf is not async-signal-safe.
    // However, it often works in simple apps or debugging. The strict approach is to use the write() system call.
    printf("\nInterrupt signal (%d) received. Shutting down...\n", signal_num);
}

// Added 'static' to fix -Wmissing-prototypes warning
static bool isDebug(void) {
    // In C, comparing string content requires strcmp; it returns 0 if equal.
    return (strcmp(BUILD_TYPE, "Debug") == 0);
}

// Added 'static' to fix -Wmissing-prototypes warning
static bool isRelease(void) {
    return (strcmp(BUILD_TYPE, "Release") == 0);
}

int main(int argc, char* argv[]) {
    // Avoid unused parameter warnings
    (void)argc;
    (void)argv;

    // 1. Set log level
    if (isRelease() == true) {
        // logger_set_level(LOG_INFO);
    } else {
        // logger_set_level(LOG_DEBUG);
    }

    // setup signal handler
    // The signal function returns the previous handler pointer, returns SIG_ERR on error.
    if (signal(SIGINT, SignalHandler) == SIG_ERR) {
        perror("Signal setup failed");
        return EXIT_FAILURE;
    }
    // signal(SIGTERM, SignalHandler);

    printf("hello %s\n", kcurrent_app_name);

    // Simulate main loop, demonstrating usage of g_stop_signal_received
    /*
    while (!g_stop_signal_received) {
        // do something...
    }
    */

    return EXIT_SUCCESS;
}