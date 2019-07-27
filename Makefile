KDIR := linux-marvell
KCFG := catdrive.config
KVER = $(shell make -s kernel_version)

CUR_DIR := $(shell pwd)
STAGE_DIR := $(CUR_DIR)/stage
OUTPUT_DIR := $(CUR_DIR)/output

MAKE_ARCH := make -C $(KDIR) CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64
J=$(shell grep ^processor /proc/cpuinfo | wc -l)

all: kernel modules
	cp -f $(KDIR)/arch/arm64/boot/Image $(OUTPUT_DIR)
	cp -f $(KDIR)/arch/arm64/boot/dts/marvell/armada-3720-catdrive.dtb $(OUTPUT_DIR)
	tar --owner=root --group=root -cJf $(OUTPUT_DIR)/modules.tar.xz -C $(STAGE_DIR) lib

kernel-config:
	cp -f $(KDIR)/$(KCFG) $(KDIR)/.config

kernel_version: kernel-config
	$(MAKE_ARCH) kernelrelease

kernel: kernel-config
	$(MAKE_ARCH) -j$(J) Image dtbs

modules: kernel-config
	$(MAKE_ARCH) -j$(J) modules
	$(MAKE_ARCH) INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(STAGE_DIR) modules_install
	rm -f $(STAGE_DIR)/lib/modules/$(KVER)/build $(STAGE_DIR)/lib/modules/$(KVER)/source

kernel_clean:
	$(MAKE_ARCH) clean

clean: kernel_clean
	rm -rf $(STAGE_DIR)
	rm -rf $(OUTPUT_DIR)/*
