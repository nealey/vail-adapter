FQBN_qtpy = adafruit:samd:adafruit_qtpy_m0
FQBN_xiao = Seeeduino:samd:seeed_XIAO_m0
UF2_MOUNT = /mnt/chromeos/removable/Arduino
ARDUINO_DIR = /usr/share/arduino
BUILDER = flatpak run --command ${ARDUINO_DIR}/arduino-builder cc.arduino.arduinoide

default: vail-adapter.qtpy.uf2 vail-adapter.xiao.uf2
install: vail-adapter.xiao.uf2
	./install.sh $< $(UF2_MOUNT) 

clean:
	rm -rf build/

# uf2conv.py is covered by an MIT license.
build/uf2conv.py: build/uf2families.json
	mkdir -p build
	curl -L https://raw.githubusercontent.com/microsoft/uf2/master/utils/$(@F) > $@
	chmod +x $@
build/uf2families.json:
	mkdir -p build
	curl -L https://raw.githubusercontent.com/microsoft/uf2/master/utils/$(@F) > $@

%.xiao.uf2: %.xiao.bin build/uf2conv.py
	build/uf2conv.py -b 0x2000 -c -o $@ $<

%.qtpy.uf2: %.qtpy.bin build/uf2conv.py
	build/uf2conv.py -b 0x2000 -c -o $@ $<

%.qtpy.bin: FQBN = adafruit:samd:adafruit_qtpy_m0
%.xiao.bin: FQBN = Seeeduino:samd:seeed_XIAO_m0
vail-adapter.%.bin: vail-adapter.ino *.cpp *.h core-%/.done
	mkdir -p build/cache
	arduino-builder \
		-build-cache build/cache \
		-build-path build/ \
		-core-api-version 10813 \
		-fqbn $(FQBN) \
		-tools $(ARDUINO_DIR)/tools \
		-tools core-$*/ArduinoCore*/ \
		-hardware $(ARDUINO_DIR)/hardware \
		-hardware core-$*/ArduinoCore* \
		-built-in-libraries $(ARDUINO_DIR)/libraries \
		-built-in-libraries core-$*/ArduinoCore*/ \
		-compile \
		$<
	mv build/vail-adapter.ino.bin $@

core-xiao/.done:
	mkdir -p $(dir $@)
	curl -L https://github.com/Seeed-Studio/ArduinoCore-samd/releases/download/v1.8.5/ArduinoCore-samd-1.8.5.tar.bz2 | tar xj -C $(dir $@)
	touch $@
	
	
upload: vail-adapter.ino
	arduino --upload --board $(FQBN) $<
