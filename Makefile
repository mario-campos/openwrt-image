OPENWRT_PROFILE = ubnt_unifiac-lite
OPENWRT_VERSION = 19.07.3
OPENWRT_TARGET1 = ath79
OPENWRT_TARGET2 = generic

OPENWRT_DIR = openwrt-imagebuilder-$(OPENWRT_VERSION)-$(OPENWRT_TARGET1)-$(OPENWRT_TARGET2).Linux-x86_64
OPENWRT_TAR = $(OPENWRT_DIR).tar.xz
OPENWRT_BIN = openwrt-$(OPENWRT_VERSION)-$(OPENWRT_TARGET1)-$(OPENWRT_TARGET2)-$(OPENWRT_PROFILE)-squashfs-sysupgrade.bin

$(OPENWRT_BIN): $(OPENWRT_DIR)
	$(MAKE) -C $(OPENWRT_DIR) \
		image \
		PROFILE=$(OPENWRT_PROFILE) \
		PACKAGES="openssh-sftp-server perl perlbase-bytes perlbase-data perlbase-digest perlbase-essential perlbase-file perlbase-xsloader coreutils-nohup sqm-scripts -ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only -opkg -swconfig -uclient-fetch" \
		CONFIG_IPV6=n

$(OPENWRT_DIR): $(OPENWRT_TAR)
	tar x -Jf $(OPENWRT_TAR)

$(OPENWRT_TAR):
	wget -q https://github.com/mario-campos/openwrt-image/releases/download/$(OPENWRT_DIR)/$(OPENWRT_TAR)

.PHONY: distclean
distclean:
	$(MAKE) -C $(OPENWRT_DIR) clean

.PHONY: clean
clean:
	rm -rf $(OPENWRT_TAR) $(OPENWRT_DIR)
