OPENWRT_TAG = v19.07.7
OPENWRT_BIN_FACTORY = openwrt/bin/targets/ath79/generic/*-factory.bin
OPENWRT_BIN_UPGRADE = openwrt/bin/targets/ath79/generic/*-sysupgrade.bin

$(OPENWRT_BIN_FACTORY) $(OPENWRT_BIN_UPGRADE): diffconfig
	git clone -b "$(OPENWRT_TAG)" --depth 1 https://git.openwrt.org/openwrt/openwrt.git
	cp diffconfig openwrt/.config
	$(MAKE) -C openwrt defconfig
	$(MAKE) -C openwrt download
	$(MAKE) -C openwrt -j$(shell nproc)

.PHONY: dirclean
dirclean:
	$(MAKE) -C openwrt dirclean

.PHONY: distclean
distclean:
	$(MAKE) -C openwrt distclean

.PHONY: clean
clean:
	$(MAKE) -C openwrt clean

UNIFI_USER = ubnt
UNIFI_PASS = ubnt
UNIFI_BIN = ubnt-unifi-3.7.58.bin

.PHONY: install
install: $(OPENWRT_BIN_FACTORY) $(UNIFI_BIN)
	export SSHPASS="$(UNIFI_PASS)" ;\
	sshpass -e scp "$(UNIFI_BIN)" $(UNIFI_USER)@$(UNIFI_HOST):/tmp/ubnt.bin ;\
	echo fwupdate.real -m /tmp/ubnt.bin | sshpass -e ssh $(UNIFI_USER)@$(UNIFI_HOST) ;\
	sshpass -e scp "$(OPENWRT_BIN_FACTORY)" $(UNIFI_USER)@$(UNIFI_HOST):/tmp/openwrt.bin ;\
	echo mtd write /tmp/openwrt.bin kernel0 | sshpass -e ssh $(UNIFI_USER)@$(UNIFI_HOST) ;\
	echo mtd erase kernel1 | sshpass -e ssh $(UNIFI_USER)@$(UNIFI_HOST) ;\
	echo 'dd bs=1 count=1 if=/dev/zero of=/dev/$$(awk "/bs/ { split(\$$0, a, \":\"); print a[1] }" </proc/mtd)' | sshpass -e ssh $(UNIFI_USER)@$(UNIFI_HOST) ;\
	echo reboot | sshpass -e ssh $(UNIFI_USER)@$(UNIFI_HOST)

$(UNIFI_BIN):
	wget -q https://github.com/mario-campos/openwrt-image/releases/download/ubnt-unifi-3-7-58-bin/$(UNIFI_BIN)
