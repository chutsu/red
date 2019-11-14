# red

Red Squadron apps and docs.


# Instructions

To setup the drone, enter the following commands in the terminal:

    wget -O setup_drone.bash https://git.io/fjcN6 && bash setup_drone.bash

Else the `make` targets are:

    qgc

      Run QGroundControl. The command will download and install
      QGroundControl for you if it does not exist.

    ubuntu18_usb

      Launch Startup Disk Creator to create a Ubuntu USB install stick.

    install_base

      Install/uninstall packages and apply settings on the Ubuntu 18.04 server
      installation.

    test_realsense

      Run a Python script to visualize the RealSense depth measurements using
      ASCII on the terminal.

    setup_time_sync_server

      Setup time sychronization server using chrony. The settings for the
      server reside in configs/chrony_server.conf.

    setup_time_sync_client

      Setup time sychronization clients using chrony. The settings for the
      client reside in configs/chrony_client.conf.


## LICENCE

BSD
