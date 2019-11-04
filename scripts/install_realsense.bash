#!/bin/bash
# Ubuntu 18.04 server Realsense installation script ############################
set -euo pipefail
IFS=$'\n\t'

install_ppa_realsense() {
	sudo apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || \
			sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
			--recv-key C8B3A55A6F3EFCDE
	sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u
	sudo apt-get -qq update
	sudo apt-get -qq install librealsense2-dkms
	sudo apt-get -qq install librealsense2-utils
	sudo apt-get -qq install librealsense2-dev

	# Install the Python wrapper
	sudo apt -qq install python3-pip
	pip3 install --user pyrealsense2
}

install_ppa_realsense
