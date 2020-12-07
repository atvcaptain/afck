# DISABLED = yes

HELP = build vendor sparse IMG Android-9

# We apply the mod only after the unpack mod
DEPS += $(STAMP.unpack)

define INSTALL
	cd $(BCT.DIR)vendor && ./build
	@echo -e " \nreplace old partition..."
	rm -f $(IMG.IN)vendor.PARTITION
	cp -v $(BCT.DIR)vendor/out/*.PARTITION $(IMG.IN) && sync
endef
