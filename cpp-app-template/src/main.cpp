#include <atomic>
#include <chrono>
#include <csignal>  // For signal handling
#include <iostream>
#include <sstream>  // For std::ostringstream
#include <string>
#include <string_view>
#include <thread>
#include <vector>

// Assume kcurrent_lib_name is available in this compilation unit
// Here we define a temporary one; in a real project, it might come from elsewhere
const std::string_view kcurrent_app_name = PROJECT_NAME;

// --- Global for signal handling ---
// static bool g_stop_signal_received = false;
static std::atomic<bool> g_stop_signal_received(false);  // Modified code

void SignalHandler(int signal_num) {
	g_stop_signal_received = true;
	std::ostringstream oss;
	oss << "\nInterrupt signal (" << signal_num << ") received. Shutting down...";
	// Use Logger instead of cerr
	std::cout << oss.str() << std::endl;
}

bool isDebug() {
	constexpr std::string_view build_type = BUILD_TYPE;
	return build_type == "Debug";
}

bool isRelease() {
	constexpr std::string_view build_type = BUILD_TYPE;
	return build_type == "Release";
}

int main(int argc, char* argv[]) {

	// 1. Set log level (e.g., only log Warning and above)
	if (isRelease() == true) {
		// logger.setLevel(kinfo);
	} else {
		// logger.setLevel(kdebug);
	}

	// setup signal handler
	signal(SIGINT, SignalHandler);
	// signal(SIGTERM, SignalHandler);

	std::cout << "hello " << kcurrent_app_name << std::endl;

	return 0;
}