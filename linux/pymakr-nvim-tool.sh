#!/bin/bash

# Check for necessary dependencies and prompt for installation
check_dependencies() {
	dependencies=("mpremote" "esptool.py" "picocom")

	for dep in "${dependencies[@]}"; do
		if ! command -v $dep &>/dev/null; then
			echo "$dep is not installed. Installing..."
			pip install $dep
		fi
	done
}

# Function to detect connected MicroPython devices
detect_devices() {
	echo "Detecting MicroPython devices..."
	devices=$(ls /dev/ttyUSB* 2>/dev/null || ls /dev/ttyACM* 2>/dev/null)

	if [ -z "$devices" ]; then
		echo "No devices found. Please connect a MicroPython board."
		exit 1
	else
		echo "Connected devices: "
		echo "$devices"
	fi
}

# Function to connect to the device and start REPL
connect_device() {
	device=$1
	echo "Connecting to $device..."
	picocom --baud 115200 $device
}

# Function to upload a file to the MicroPython device
upload_file() {
	device=$1
	file=$2
	echo "Uploading $file to $device..."
	mpremote connect $device fs cp $file :
}

# Function to download a file from the MicroPython device
download_file() {
	device=$1
	file=$2
	echo "Downloading $file from $device..."
	mpremote connect $device fs cp :$file .
}

# Function to sync a local directory with the MicroPython device
sync_directory() {
	device=$1
	local_dir=$2
	echo "Syncing local directory $local_dir with device..."
	mpremote connect $device fs cp -r $local_dir :
}

# Function to reset the MicroPython device
reset_device() {
	device=$1
	echo "Resetting $device..."
	mpremote connect $device reset
}

# Function to flash new firmware to the MicroPython device
flash_firmware() {
	device=$1
	firmware=$2
	echo "Flashing firmware to $device..."
	esptool.py --port $device write_flash 0x1000 $firmware
}

# Interactive menu to choose operations
menu() {
	echo "Pymakr-like MicroPython Tool"
	echo "1. Detect devices"
	echo "2. Connect to device (REPL)"
	echo "3. Upload file"
	echo "4. Download file"
	echo "5. Sync directory"
	echo "6. Reset device"
	echo "7. Flash firmware"
	echo "8. Exit"
	read -p "Choose an option: " choice

	case $choice in
	1) detect_devices ;;
	2)
		read -p "Enter device path: " device
		connect_device $device
		;;
	3)
		read -p "Enter device path: " device
		read -p "Enter file to upload: " file
		upload_file $device $file
		;;
	4)
		read -p "Enter device path: " device
		read -p "Enter file to download: " file
		download_file $device $file
		;;
	5)
		read -p "Enter device path: " device
		read -p "Enter local directory to sync: " local_dir
		sync_directory $device $local_dir
		;;
	6)
		read -p "Enter device path: " device
		reset_device $device
		;;
	7)
		read -p "Enter device path: " device
		read -p "Enter firmware file path: " firmware
		flash_firmware $device $firmware
		;;
	8) exit 0 ;;
	*) echo "Invalid option" ;;
	esac
}

# Check dependencies before running the script
check_dependencies

# Main loop to show the interactive menu
while true; do
	menu
done
