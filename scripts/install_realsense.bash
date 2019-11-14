#!/bin/bash
# Ubuntu 18.04 server Realsense installation script ############################
set -euo pipefail
IFS=$'\n\t'

# DEPS
apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
apt autoremove
apt-get install \
  git \
  libssl-dev \
  libusb-1.0-0-dev \
  pkg-config \
  libgtk-3-dev \
  libglfw3-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev

# CLONE REPO
if [ ! -d "/usr/local/src/librealsense" ]; then
  cd /usr/local/src
  git clone https://github.com/IntelRealSense/librealsense
fi

# BUILD REPO
cd /usr/local/src/librealsense
./scripts/setup_udev_rules.sh
./scripts/patch-realsense-ubuntu-lts.sh
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
make install
