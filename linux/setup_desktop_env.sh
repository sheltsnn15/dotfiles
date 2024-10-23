#!/bin/bash

# Error handling
set -e

# Logging function
log() {
	printf "%s\n" "$1"
}

# Function to update and upgrade system
update_system() {
	log "Updating and upgrading system..."
	sudo apt-get update
	sudo apt-get upgrade -y
}

# Function to configure XRDP
configure_xrdp() {
	log "Configuring XRDP..."
	sudo apt-get install -y xrdp
	sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak || true
	sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
	sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
	sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
}

# Function to install additional packages for XFCE4+i3
install_xfce4_i3_packages() {
	log "Installing additional packages for XFCE4+i3..."
	sudo apt-get install -y lightdm xubuntu arc-theme papirus-icon-theme gvfs gvfs-backends i3* dmenu suckless-tools feh lxappearance breeze-icon-theme picom arc-theme papirus-icon-theme
}

# Function to apply EndeavourOS theming for XFCE4
apply_endeavouros_xfce4_theming() {
	log "Applying EndeavourOS theming for XFCE4..."
	git clone https://github.com/endeavouros-team/endeavouros-xfce4-theming ~/Documents/Packages/endeavouros-xfce4-theming
	cd ~/Documents/Packages/endeavouros-xfce4-theming/etc/skel/
	rm -rf ~/.config/xfce4 ~/.cache
	cp -R .config/ ~/
}

# Function to set up i3 as the window manager
setup_i3wm() {
	log "Setting up i3 as the window manager..."
	xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -sa xfsettingsd
	xfconf-query -c xfce4-session -p /sessions/Failsafe/Client1_Command -t string -sa i3
	xfconf-query -c xfce4-session -p /sessions/Failsafe/Client2_Command -t string -sa xfce4-panel
	xfconf-query -c xfce4-session -p /sessions/Failsafe/Client3_Command -t string -s thunar -t string -s --daemon

	git clone https://github.com/endeavouros-team/endeavouros-i3wm-setup.git ~/Documents/Packages/endeavouros-i3wm-setup
	cd ~/Documents/Packages/endeavouros-i3wm-setup/etc/skel/
	cp .Xresources "${HOME}"/.Xresources
	cp -R .config/* "${HOME}"/.config/
	chmod -R +x "${HOME}"/.config/i3/scripts
}

# Function to install Snap packages
install_snap_packages() {
	log "Installing Snap packages..."
	sudo apt-get install -y snapd
	sudo snap install rambox
	sudo snap install postman
	sudo snap install drawio
	sudo snap install code --classic
	sudo snap install bitwarden
	sudo snap install obsidian --classic
}

# Function to set up Git configuration
setup_git() {
	log "Setting up Git global configuration..."
	git config --global user.name "Shelton Ngwenya"
	git config --global user.email "shelt15.nn@gmail.com"
}

# Function to generate SSH key and add it to GitHub using the GitHub CLI
setup_ssh_key_for_github() {
	log "Generating SSH key for GitHub..."
	ssh-keygen -t ed25519 -C "shelt15.nn@gmail.com" -f ~/.ssh/id_ed25519 -N ""
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_ed25519
	log "SSH key generated."

	log "Adding SSH key to GitHub using gh CLI..."
	if ! command -v gh &>/dev/null; then
		log "GitHub CLI (gh) is not installed. Installing..."
		sudo apt-get install -y gh
	fi
	gh auth login
	gh ssh-key add ~/.ssh/id_ed25519.pub --title "My SSH Key"
	log "SSH key added to GitHub."
}

# Run all functions in order
update_system
# configure_xrdp
install_xfce4_i3_packages
apply_endeavouros_xfce4_theming
setup_i3wm
install_snap_packages

log "All tasks completed successfully!"
