# Intel RealSense D435i calibration guide
It is assumed that `librealsense` is already installed on the system. To
install on Linux follow the instructions
[here](https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md).


## Camera calibration
[Intel calibration manual]

1. Download the Android app for showing the calibration target from
   [here.](https://play.google.com/store/apps/details?id=com.intel.realsenseviewer17613)

2. Run the commands below to install the calibration app on Ubuntu 18.04 (taken
   from section 3.1 of the [Intel calibration manual]).
    ``` bash
    # Install dependencies
    sudo apt update
    sudo apt -y install libusb-dev libusb-1.0-0-dev
    sudo apt -y install libglfw3 libglfw3-dev
    sudo apt -y install freeglut3 freeglut3-dev
    wget -q -O /tmp/libpng12.deb http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
    sudo dpkg -i /tmp/libpng12.deb

    # Install calibration tool
    sudo apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE
    sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u
    sudo rm -f /etc/apt/sources.list.d/realsense-public.list
    sudo apt update
    sudo apt -y install librscalibrationtool
    sudo apt -y install librealsense2-dkms

    # Show the tool version
    Intel.Realsense.DynamicCalibrator -v
    ```

3. Plug in the camera, launch `Intel.Realsense.DynamicCalibrator` and start the
   calibration target app on the phone.

4. Follow the instructions in `Intel.Realsense.DynamicCalibrator`.

5. The folder `~/DyCalibResult` contains the calibration results.



## IMU calibration
[Intel IMU calibration manual]

1. Install the dependencies and download the calibration script.
    ``` bash
    # Install dependencies
    sudo apt -y install python3 python3-pip
    sudo -H pip3 install numpy
    sudo -H pip3 install pyrealsense2
    
    # Download the calibration script
    wget -O /tmp/rs-imu-calibration.py https://raw.githubusercontent.com/IntelRealSense/librealsense/master/tools/rs-imu-calibration/rs-imu-calibration.py
    ```

2. Connect the camera and run the calibration script with `python3
   /tmp/rs-imu-calibration.py`. You might want to do the box trick mentioned
[here](https://github.com/IntelRealSense/librealsense/tree/master/tools/rs-imu-calibration).



[Intel calibration manual]: https://www.intel.com/content/dam/support/us/en/documents/emerging-technologies/intel-realsense-technology/RealSense_D400_Dyn_Calib_User_Guide.pdf
[Intel IMU calibration manual]: https://realsense.intel.com/wp-content/uploads/sites/63/Intel_RealSense_Depth_D435i_IMU_Calibration.pdf

