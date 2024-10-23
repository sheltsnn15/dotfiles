#!/bin/bash

# Check for necessary dependencies and prompt for installation
check_dependencies() {
	dependencies=("platformio" "jq")

	for dep in "${dependencies[@]}"; do
		if ! command -v $dep &>/dev/null; then
			echo "$dep is not installed. Installing..."
			pip install $dep
		fi
	done
}

# Function to detect connected boards
detect_board() {
	echo "Detecting connected boards..."
	# List all connected serial devices (USB, ACM)
	device=$(ls /dev/ttyUSB* 2>/dev/null || ls /dev/ttyACM* 2>/dev/null)

	if [ -z "$device" ]; then
		echo "No connected boards found."
		return 1
	else
		echo "Detected board on: $device"
		return 0
	fi
}

# Function to parse platformio.ini and list environments
list_environments() {
	echo "Listing environments from platformio.ini..."
	environments=$(grep -oP '\[env:[^\]]+' platformio.ini | cut -d: -f2)

	if [ -z "$environments" ]; then
		echo "No environments found in platformio.ini."
		exit 1
	fi

	echo "Available environments:"
	echo "$environments"
}

# Function to select environment
select_environment() {
	if detect_board; then
		# Auto-select environment based on board type (could add more sophisticated detection here)
		if echo "$environments" | grep -q "esp32"; then
			echo "Auto-selecting 'esp32' environment."
			selected_env="esp32"
		else
			echo "Multiple environments found, please select one:"
			echo "$environments"
			read -p "Enter the environment name: " selected_env
		fi
	else
		# Manual selection if no board is detected
		echo "No boards detected. Please select an environment:"
		echo "$environments"
		read -p "Enter the environment name: " selected_env
	fi
}

# Function to initialize or open a PlatformIO project
init_project() {
	read -p "Enter the directory where you want to initialize the project (or open existing): " project_dir
	mkdir -p $project_dir
	cd $project_dir
	if [ ! -f platformio.ini ]; then
		echo "Initializing new PlatformIO project..."
		pio project init
	else
		echo "PlatformIO project detected."
	fi

	# List environments after initializing the project
	list_environments
}

# Function to build the PlatformIO project
build_project() {
	select_environment
	echo "Building the PlatformIO project for environment: $selected_env..."
	pio run -e $selected_env

	# Generate compile_commands.json after building the project
	generate_compile_commands
}

# Function to generate compile_commands.json
generate_compile_commands() {
	echo "Generating compile_commands.json for LSP integration..."
	# Use PlatformIO's extra_scripts to generate compile_commands.json
	if [ ! -d .pio/build/$selected_env ]; then
		echo "Build directory for environment $selected_env not found!"
		exit 1
	fi

	compile_db=".pio/build/$selected_env/compile_commands.json"
	if [ -f $compile_db ]; then
		echo "compile_commands.json already exists."
	else
		echo "Generating compile_commands.json..."
		pio run -t compiledb -e $selected_env
	fi

	# Check if Neovim LSP is properly configured to use this file
	if [ -f $compile_db ]; then
		echo "compile_commands.json generated at $compile_db"
	else
		echo "Failed to generate compile_commands.json."
	fi
}

# Function to upload the firmware to the microcontroller
upload_firmware() {
	select_environment
	echo "Uploading firmware to the device for environment: $selected_env..."
	pio run -t upload -e $selected_env
}

# Function to open the serial monitor
open_serial_monitor() {
	echo "Opening the serial monitor..."
	pio device monitor
}

# Function to clean the build files
clean_project() {
	select_environment
	echo "Cleaning the PlatformIO project..."
	pio run --target clean -e $selected_env
}

# Function to run tests
run_tests() {
	select_environment
	echo "Running tests for the PlatformIO project..."
	pio test -e $selected_env
}

# Function to install project dependencies
install_dependencies() {
	echo "Installing project dependencies..."
	pio lib install
}

# Function to manage platforms and libraries
manage_platforms_and_libraries() {
	echo "Managing platforms and libraries..."
	echo "1. Install Platform"
	echo "2. Install Library"
	read -p "Choose an option: " choice

	case $choice in
	1)
		read -p "Enter the platform you want to install (e.g., espressif32): " platform
		pio platform install $platform
		;;
	2)
		read -p "Enter the library you want to install: " library
		pio lib install $library
		;;
	*)
		echo "Invalid option"
		;;
	esac
}

# Interactive menu to choose operations
menu() {
	echo "PlatformIO CLI Tool"
	echo "1. Initialize/Open PlatformIO project"
	echo "2. Build the project and generate compile_commands.json"
	echo "3. Upload firmware"
	echo "4. Open serial monitor"
	echo "5. Clean the project"
	echo "6. Run tests"
	echo "7. Install project dependencies"
	echo "8. Manage platforms and libraries"
	echo "9. Exit"
	read -p "Choose an option: " choice

	case $choice in
	1) init_project ;;
	2) build_project ;;
	3) upload_firmware ;;
	4) open_serial_monitor ;;
	5) clean_project ;;
	6) run_tests ;;
	7) install_dependencies ;;
	8) manage_platforms_and_libraries ;;
	9) exit 0 ;;
	*) echo "Invalid option" ;;
	esac
}

# Check dependencies before running the script
check_dependencies

# Main loop to show the interactive menu
while true; do
	menu
done
