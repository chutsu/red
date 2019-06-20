#!/bin/bash
set -e  # Exit on first error

rm -rf $HOME/* # Clear all folders
sudo apt-get -qq install git make

git clone https://github.com/chutsu/red
cd red
make install_base
make install_ros
