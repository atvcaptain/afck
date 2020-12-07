#
# Replacing the kernel and modules in the firmware Bilink for the drain
#

BOOT_IMG = ingredients/x96max-stock-boot-$(VARIANT).img.lzma
BOOT_TAR = ingredients/x96max-stock-modules.tar.lzma
$(call ASSERT.FILE,$(BOOT_IMG))
$(call ASSERT.FILE,$(BOOT_TAR))

HELP = Замена ядра и драйверов на стоковые

$(call IMG.UNPACK.EXT4,vendor)

# We'll provide the boot section ourselves
$(call IMG.WILL.BUILD,boot)

# The rule to copy the kernel
$(IMG.OUT)boot.PARTITION: $(BOOT_IMG) | $(IMG.OUT).stamp.dir
	lzma -d $< -c >$@

define INSTALL
	rm -rf $/vendor/lib/modules/*
	tar xf $(BOOT_TAR) --lzma -C $/vendor/lib/modules/
endef

DESC
The firmware has a drain core with all its advantages and disadvantages:
* The clock on the front panel is running
* Poor quality playback of line video without libamcodec
endef
