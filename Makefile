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

deps: ${QGROUNDCONTROL}

qgc: ${QGROUNDCONTROL}
	${QGROUNDCONTROL}
