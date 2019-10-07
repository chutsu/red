#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

install_ros() {
	# http://wiki.ros.org/melodic/Installation/Ubuntu
	# Setup repository
	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
			--recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
	sudo apt update
	# Install ros
	sudo apt install ros-melodic-ros-base python-rosinstall python-catkin-tools
	# Initialize rosdep
	sudo rosdep init
	rosdep update
}

install_ros
