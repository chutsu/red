#!/bin/bash
set -e  # Exit on first error

rm -rf $HOME/* # Clear all folders
sudo apt-get -qq install git

git clone https://github.com:chutsu/red
cd red
make drone_setup_base
