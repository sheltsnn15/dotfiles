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

# Function to install Firefox from Mozilla APT Repository
install_firefox() {
	log "Installing Firefox from Mozilla APT Repository..."
	if ! dpkg -s firefox &>/dev/null; then
		sudo install -d -m 0755 /etc/apt/keyrings
		wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
		FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')
		if [ "$FINGERPRINT" == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]; then
			log "The key fingerprint matches ($FINGERPRINT)."
		else
			log "Verification failed: the fingerprint ($FINGERPRINT) does not match the expected one."
			exit 1
		fi
		echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null
		echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
		sudo apt-get update
		sudo apt-get install -y firefox
	else
		log "Firefox is already installed."
	fi
}

# Function to install additional packages for XFCE4+i3
install_xfce4_i3_packages() {
	log "Installing additional packages for XFCE4+i3..."
	sudo apt-get install -y lightdm xfce4 xfce4-goodies arc-theme papirus-icon-theme gvfs gvfs-backends i3* dmenu suckless-tools feh lxappearance picom arc-theme papirus-icon-theme
}

# Function to apply EndeavourOS theming for XFCE4
apply_endeavouros_xfce4_theming() {
	log "Applying EndeavourOS theming for XFCE4..."
	git clone https://github.com/endeavouros-team/endeavouros-xfce4-theming ~/Documents/Packages/endeavouros-xfce4-theming
	cd ~/Documents/Packages/endeavouros-xfce4-theming/etc/skel/

	rm -rf ~/.config/xfce4 ~/.cache

	cp .Xresources ~/.Xresources
	cp .face ~/.face
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

# Run all functions in order
update_system
# configure_xrdp
install_firefox
install_xfce4_i3_packages
apply_endeavouros_xfce4_theming
setup_i3wm

log "All tasks completed successfully!"
