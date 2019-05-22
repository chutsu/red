include config.mk

default: dirs deps

dirs:
	@mkdir -p deps

clean:
	@rm -rf deps

${QGROUNDCONTROL}:
	@echo "[Installing QGroundControl]"
	@sudo usermod -a -G dialout ${USER}
	@sudo apt-get remove modemmanager -y -qqq
	@sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav -y -qqq
	@wget ${QGROUNDCONTROL_URL} -P ${DEPS_DIR}
	@chmod +x ${DEPS_DIR}/QGroundControl.AppImage

ubuntu18_usb:
	@echo "[Create Ubuntu install USB stick]"
	@sudo usb-creator-gtk

drone_setup_base:
	./scripts/Ubuntu_1804_server_setup.sh

drone_setup_ros:
	./scripts/Ubuntu_1804_server_ros_setup.sh

drone_setup_realsense:
	./scripts/Ubuntu_1804_server_realsense_setup.sh

drone_test_realsense:
	./scripts/test_realsense_output.py

setup_time_sync_server:
	@sudo apt-get remove ntp ntpdate -qq
	@sudo apt-get install chrony -qq
	@sudo cp configs/chrony_server.conf /etc/chrony/chrony.conf
	@sudo systemctl restart chrony.service
	@sleep 2
	@sudo systemctl --no-pager status chrony.service
	chronyc sourcestats

setup_time_sync_client:
	@sudo apt-get remove ntp ntpdate -qq
	@sudo apt-get install chrony -qq
	@sudo cp configs/chrony_client.conf /etc/chrony/chrony.conf
	@sudo systemctl restart chrony.service
	@sleep 2
	@sudo systemctl --no-pager status chrony.service
	chronyc sources

deps: ${QGROUNDCONTROL}

qgc: ${QGROUNDCONTROL}
	${QGROUNDCONTROL}
