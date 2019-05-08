#!/bin/bash
set -e  # Exit on first error

sudo apt-get -qq install git
git clone git@github.com:chutsu/red.git
cd red
make drone_setup_base
