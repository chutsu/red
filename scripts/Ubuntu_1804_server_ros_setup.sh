#!/bin/bash
# Ubuntu 18.04 server ROS installation script ##################################
set -euo pipefail
IFS=$'\n\t'

install-ros() {
	# http://wiki.ros.org/melodic/Installation/Ubuntu
	# Setup repository
	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
			--recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
	sudo apt update
	# Install ros
	sudo apt install ros-melodic-ros-base python-rosinstall python-catkin-tools
	# Initialize rosdep
	sudo rosdep init
	rosdep update
}

install-ros

