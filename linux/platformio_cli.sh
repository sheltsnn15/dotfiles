#!/usr/bin/env bash
#
# platformio_cli.sh
#
# Description:
#   This script emulates some core features of the PlatformIO VSCode extension:
#   - Project initialization/opening
#   - Environment listing and selection
#   - Building, testing, uploading, and running (native)
#   - Opening a serial monitor
#   - Managing platforms and libraries
#   - Generating compile_commands.json
#
# Prerequisites:
#   - PlatformIO installed (via official installer script):
#       https://docs.platformio.org/en/latest/core/installation/methods/installer-script.html
#   - 'jq' installed via your system’s package manager (apt, yum, brew, etc.)
#
# Usage:
#   ./platformio_cli.sh [--verbose] [--help] [--build] [--upload] [--run-native]
#   - --verbose: Enable detailed logging
#   - --help:    Show usage
#   - --build:   Immediately build the project (bypasses the menu)
#   - --upload:  Immediately upload firmware (bypasses the menu)
#   - --run-native: Immediately run the native binary (bypasses the menu)
#
#   Otherwise, the script will open an interactive menu.
#

set -e
set -o pipefail

########################################
# Global Variables / ANSI color codes
########################################
verbose=false
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

########################################
# Logging functions
########################################
log() {
	local level="$1"
	local message="$2"
	if [[ "$level" == *"[INFO]"* ]]; then
		# Only print info messages if verbose
		[[ "$verbose" = true ]] && echo -e "${level}${message}${RESET}"
	else
		# For WARN or ERROR, always print
		echo -e "${level}${message}${RESET}"
	fi
}

info() { log "$GREEN[INFO]" "$1"; }
warn() { log "$YELLOW[WARN]" "$1"; }
error() { log "$RED[ERROR]" "$1"; }

########################################
# Command-line Argument Parsing
########################################
for arg in "$@"; do
	case $arg in
	--verbose)
		verbose=true
		shift
		;;
	--help)
		echo "Usage: $0 [--verbose] [--help] [--build] [--upload] [--run-native]"
		echo "  --verbose    Enable detailed logging"
		echo "  --help       Display this help message"
		echo "  --build      Immediately build the project (skips menu)"
		echo "  --upload     Immediately upload firmware (skips menu)"
		echo "  --run-native Immediately run the native binary (skips menu)"
		exit 0
		;;
	--build)
		build_flag=true
		;;
	--upload)
		upload_flag=true
		;;
	--run-native)
		run_native_flag=true
		;;
	esac
done

########################################
# Check Dependencies
########################################
check_dependencies() {
	# Check for either 'pio' or 'platformio'
	if command -v pio &>/dev/null; then
		info "Found 'pio' command."
	elif command -v platformio &>/dev/null; then
		info "Found 'platformio' command."
	else
		warn "PlatformIO is not installed on your system."
		warn "Please install it using the official installer script:"
		warn "    https://docs.platformio.org/en/latest/core/installation/methods/installer-script.html"
		error "Exiting..."
		exit 1
	fi

	# Check if jq is installed
	if ! command -v jq &>/dev/null; then
		warn "jq is not installed on your system."
		warn "Please install 'jq' via your system's package manager (apt, yum, brew, etc.) and re-run this script."
		error "Exiting..."
		exit 1
	fi
}

########################################
# platformio.ini Validation
########################################
validate_platformio_ini() {
	if ! [ -f platformio.ini ]; then
		error "platformio.ini not found!"
		return 1
	fi
	if ! grep -q '\[env:' platformio.ini; then
		error "No valid environments found in platformio.ini."
		return 1
	fi
	return 0
}

########################################
# Better Board Detection with JSON
########################################
detect_board() {
	info "Detecting connected boards via JSON output..."
	# We assume 'jq' is installed (checked above).
	mapfile -t devices < <(pio device list --json-output | jq -r '.[].port')

	if [ ${#devices[@]} -eq 0 ]; then
		error "No connected boards found."
		return 1
	elif [ ${#devices[@]} -eq 1 ]; then
		info "Detected board on: ${devices[0]}"
		device="${devices[0]}"
	else
		echo "Multiple boards detected:"
		for i in "${!devices[@]}"; do
			echo "$i) ${devices[$i]}"
		done
		while true; do
			read -p "Select a board by index: " index
			if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -lt "${#devices[@]}" ]; then
				device="${devices[$index]}"
				info "Selected board: $device"
				break
			else
				error "Invalid index. Please select a valid option."
			fi
		done
	fi
	return 0
}

########################################
# List Environments in platformio.ini
########################################
list_environments() {
	validate_platformio_ini || exit 1
	info "Listing environments from platformio.ini..."
	environments=$(grep -oP '\[env:[^\]]+' platformio.ini | cut -d: -f2)
	if [ -z "$environments" ]; then
		error "No environments found in platformio.ini."
		exit 1
	fi
	echo "$environments"
}

########################################
# Prompt User for Input (non-empty)
########################################
get_user_input() {
	local prompt="$1"
	local input
	while true; do
		read -p "$prompt" input
		if [ -n "$input" ]; then
			echo "$input"
			break
		else
			error "Input cannot be empty. Please try again."
		fi
	done
}

########################################
# Enhanced Environment Selection
########################################
select_environment() {
	list_environments

	if detect_board; then
		# Try to auto-match environment name with the selected device path
		matching_env=$(echo "$environments" | grep -m1 "$device" || true)
		if [ -n "$matching_env" ]; then
			info "Auto-selecting environment based on detected board: $matching_env"
			selected_env="$matching_env"
		else
			warn "No matching environment found for the detected board. Please select an environment."
			echo "$environments"
			selected_env=$(get_user_input "Enter the environment name: ")
		fi
	else
		warn "No boards detected or no valid environment match."
		info "Available environments:"
		echo "$environments"
		selected_env=$(get_user_input "Enter the environment name: ")
	fi
}

########################################
# Initialize or Open a PlatformIO Project
########################################
init_project() {
	local project_dir
	project_dir=$(get_user_input "Enter the directory where you want to initialize the project (or open existing): ")

	# Ensure directory exists
	if [ ! -d "$project_dir" ]; then
		info "Directory '$project_dir' does not exist. Creating it..."
		mkdir -p "$project_dir"
	fi

	# Attempt to cd into it
	cd "$project_dir" || {
		error "Failed to navigate to '$project_dir'. Exiting..."
		exit 1
	}

	if [ -f platformio.ini ]; then
		warn "A 'platformio.ini' file already exists in this directory."
		warn "Continuing with the existing project."
	else
		info "Initializing new PlatformIO project..."
		pio project init
	fi

	list_environments
}

########################################
# Extract 'platform' from a given env
########################################
get_platform_for_env() {
	local env_name="$1"
	grep -A 5 "\[env:$env_name\]" platformio.ini | grep "platform" | head -n1 | cut -d= -f2 | tr -d ' '
}

########################################
# Build the PlatformIO Project
########################################
build_project() {
	select_environment
	info "Building the PlatformIO project for environment: $selected_env..."
	if ! pio run -e "$selected_env"; then
		error "Build failed."
		exit 1
	fi
	generate_compile_commands

	# If the environment is native, offer to run the binary
	if [ "$(get_platform_for_env "$selected_env")" == "native" ]; then
		ask_to_run_native_binary
	fi
}

########################################
# Ask to Run Native Binary
########################################
ask_to_run_native_binary() {
	local run_binary
	run_binary=$(get_user_input "Do you want to run the native binary now? (y/n): ")
	if [[ "$run_binary" =~ ^[Yy]$ ]]; then
		run_native_binary
	fi
}

########################################
# Run the Native Binary
########################################
run_native_binary() {
	# Prompt user to select an environment
	select_environment

	# Check if the selected environment is native
	if [ "$(get_platform_for_env "$selected_env")" == "native" ]; then
		info "Running the native binary for environment: $selected_env..."
		local binary_path=".pio/build/$selected_env/program"

		# Check if the compiled binary exists
		if [ -f "$binary_path" ]; then
			info "Executing $binary_path"
			"$binary_path"
		else
			error "Compiled binary not found at $binary_path"
			# Ask the user if they want to build the project
			local build_choice
			build_choice=$(get_user_input "Would you like to build the project first? (y/n): ")
			if [[ "$build_choice" =~ ^[Yy]$ ]]; then
				build_project
				# After building, check again if the binary exists
				if [ -f "$binary_path" ]; then
					info "Executing $binary_path"
					"$binary_path"
				else
					error "Build failed or binary still not found."
					exit 1
				fi
			else
				error "Cannot run the binary without building it first."
			fi
		fi
	else
		error "Selected environment '$selected_env' is not a native environment."
	fi
}

########################################
# Generate compile_commands.json
########################################
generate_compile_commands() {
	info "Generating compile_commands.json for LSP integration..."
	if [ ! -d .pio/build/"$selected_env" ]; then
		error "Build directory for environment $selected_env not found!"
		exit 1
	fi

	local compile_db=".pio/build/$selected_env/compile_commands.json"
	if [ -f "$compile_db" ]; then
		warn "compile_commands.json already exists."
	else
		info "Generating compile_commands.json..."
		if ! pio run -t compiledb -e "$selected_env"; then
			error "Failed to generate compile_commands.json."
			exit 1
		fi
	fi
}

########################################
# Upload Firmware
########################################
upload_firmware() {
	select_environment
	if [ "$(get_platform_for_env "$selected_env")" == "native" ]; then
		warn "Upload is not applicable for the native environment."
	else
		info "Uploading firmware to the device for environment: $selected_env..."
		if ! pio run -t upload -e "$selected_env"; then
			error "Upload failed."
			exit 1
		fi
	fi
}

########################################
# Open the Serial Monitor
########################################
open_serial_monitor() {
	local baud_rate
	baud_rate=$(get_user_input "Enter the baud rate for the serial monitor (default 9600): ")
	baud_rate="${baud_rate:-9600}"
	info "Opening the serial monitor at baud rate: $baud_rate..."
	if ! pio device monitor --baud "$baud_rate"; then
		error "Failed to open serial monitor."
		exit 1
	fi
}

########################################
# Clean the Project
########################################
clean_project() {
	select_environment
	info "Cleaning the PlatformIO project for environment: $selected_env..."
	if ! pio run --target clean -e "$selected_env"; then
		error "Clean failed."
		exit 1
	fi
}

########################################
# Run Tests
########################################
run_tests() {
	select_environment
	info "Running tests for the PlatformIO project..."
	if ! pio test -e "$selected_env"; then
		error "Tests failed."
		exit 1
	fi
}

########################################
# Install Project Dependencies
########################################
install_dependencies() {
	info "Installing project dependencies (libraries in platformio.ini)..."
	if ! pio lib install; then
		error "Failed to install dependencies."
		exit 1
	fi
}

########################################
# Manage Platforms and Libraries
########################################
manage_platforms_and_libraries() {
	info "Managing platforms and libraries..."
	echo "1. Install Platform"
	echo "2. Uninstall Platform"
	echo "3. Install Library"
	echo "4. Uninstall Library"
	echo "0. Return to main menu"
	local choice
	choice=$(get_user_input "Choose an option: ")

	case $choice in
	1)
		local platform
		platform=$(get_user_input "Enter the platform you want to install (e.g., espressif32): ")
		if ! pio pkg install -p "$platform"; then
			error "Failed to install platform."
		fi
		;;
	2)
		local platform
		platform=$(get_user_input "Enter the platform you want to uninstall: ")
		if ! pio pkg uninstall -p "$platform"; then
			error "Failed to uninstall platform."
		fi
		;;
	3)
		local library
		library=$(get_user_input "Enter the library you want to install: ")
		if ! pio pkg install -l "$library"; then
			error "Failed to install library."
		fi
		;;
	4)
		local library
		library=$(get_user_input "Enter the library you want to uninstall: ")
		if ! pio pkg uninstall -l "$library"; then
			error "Failed to uninstall library."
		fi
		;;
	0)
		info "Returning to main menu..."
		return
		;;
	*)
		error "Invalid option"
		;;
	esac
}

########################################
# Update PlatformIO, Libraries, Platforms
########################################
update_all() {
	info "Updating PlatformIO, libraries, and platforms..."
	if ! pio pkg update; then
		error "Update failed."
		exit 1
	fi
}

########################################
# Main Interactive Menu
########################################
menu() {
	echo
	echo "=============== PlatformIO CLI Tool ==============="
	echo "1) Initialize/Open PlatformIO project"
	echo "2) Build the project + generate compile_commands.json"
	echo "3) Upload firmware"
	echo "4) Open serial monitor"
	echo "5) Clean the project"
	echo "6) Run tests"
	echo "7) Install project dependencies"
	echo "8) Manage platforms and libraries"
	echo "9) Update PlatformIO, libraries, and platforms"
	echo "10) Run native binary"
	echo "11) Exit"
	echo "===================================================="
	local choice
	choice=$(get_user_input "Choose an option: ")

	case $choice in
	1) init_project ;;
	2) build_project ;;
	3) upload_firmware ;;
	4) open_serial_monitor ;;
	5) clean_project ;;
	6) run_tests ;;
	7) install_dependencies ;;
	8) manage_platforms_and_libraries ;;
	9) update_all ;;
	10) run_native_binary ;;
	11) exit 0 ;;
	*) error "Invalid option" ;;
	esac
}

########################################
# Script Execution Begins Here
########################################
check_dependencies

# If the user supplied an immediate flag to do something, handle it now:
if [ "${build_flag:-false}" = true ]; then
	build_project
	exit 0
fi

if [ "${upload_flag:-false}" = true ]; then
	upload_firmware
	exit 0
fi

if [ "${run_native_flag:-false}" = true ]; then
	run_native_binary
	exit 0
fi

# Otherwise, launch the interactive menu
while true; do
	menu
done
