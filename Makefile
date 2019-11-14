include config.mk

default: dirs deps

.PHONY: dirs
dirs:
	@mkdir -p deps

.PHONY: clean
clean:
	@rm -rf deps

${QGROUNDCONTROL}:
	@echo "[Installing QGroundControl]"
	@sudo usermod -a -G dialout ${USER}
	@sudo apt-get remove modemmanager -y -qqq
	@sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav -y -qqq
	@wget ${QGROUNDCONTROL_URL} -P ${DEPS_DIR}
	@chmod +x ${DEPS_DIR}/QGroundControl.AppImage

.PHONY: ubuntu18_usb
ubuntu18_usb:
	@echo "[Create Ubuntu install USB stick]"
	@sudo usb-creator-gtk

.PHONY: install_base
install_base:
	./scripts/install_base.bash
	./scripts/install_ros.bash
	./scripts/install_realsense.bash

.PHONY: test_realsense
test_realsense:
	./scripts/test_realsense_output.py

.PHONY: setup_time_sync_server
setup_time_sync_server:
	@sudo apt-get remove ntp ntpdate -qq
	@sudo apt-get install chrony -qq
	@sudo cp configs/chrony_server.conf /etc/chrony/chrony.conf
	@sudo systemctl restart chrony.service
	@sleep 2
	@sudo systemctl --no-pager status chrony.service
	chronyc sourcestats

.PHONY: setup_time_sync_client
setup_time_sync_client:
	@sudo apt-get remove ntp ntpdate -qq
	@sudo apt-get install chrony -qq
	@sudo cp configs/chrony_client.conf /etc/chrony/chrony.conf
	@sudo systemctl restart chrony.service
	@sleep 2
	@sudo systemctl --no-pager status chrony.service
	chronyc sources

.PHONY: deps
deps: ${QGROUNDCONTROL}

.PHONY: qgc
qgc: ${QGROUNDCONTROL}
	${QGROUNDCONTROL}
