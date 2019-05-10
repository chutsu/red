#!/bin/bash
# Ubuntu 18.04 server installation script ######################################
set -euo pipefail
IFS=$'\n\t'

uninstall-packages() {
	sudo apt-get -qq purge snapd # Snap packages are useless
	sudo apt-get -qq purge unattended-upgrades # Disable automatic updates
	sudo apt-get -qq autoremove
	echo "Packages uninstalled ###############################################"
}

install-packages() {
	sudo apt-get -qq install atool # Easily unpack any archive
	sudo apt-get -qq install build-essential # Common developer packages (make, gcc, g++ etc.)
	sudo apt-get -qq install cmake
	sudo apt-get -qq install curl
	sudo apt-get -qq install gdb
	sudo apt-get -qq install git
	sudo apt-get -qq install htop
	sudo apt-get -qq install openssh-server
	sudo apt-get -qq install moreutils # Extra utilities
	sudo apt-get -qq install p7zip-full p7zip-rar # Unpack 7zip and rar archives
	sudo apt-get -qq install powertop # Report power usage
	sudo apt-get -qq install python-pip python3-pip
	sudo apt-get -qq install rsync # Efficiently transfer files over the network
	sudo apt-get -qq install screen
	sudo apt-get -qq install vifm # File manager with vi-like keybindings
	sudo apt-get -qq install vim
	sudo apt-get -qq install w3m # Text web browser
	echo "Packages installed #################################################"
}

configure-logs() {
	# Limit the maximum systemd log size to 100 MiB
	echo "SystemMaxUse=100M" | sudo tee -a /etc/systemd/journald.conf > /dev/null
	echo "Maximum log size reduced ###########################################"
}

enable-sysrq() {
	# https://en.wikipedia.org/wiki/Magic_SysRq_key
	echo "# Enable SysRq commands" | sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null
	echo "kernel.sysrq = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null
	echo "sysrq commands enabled #############################################"
}

install-base() {
	uninstall-packages
	install-packages
	configure-logs
	enable-sysrq
}

install-base

