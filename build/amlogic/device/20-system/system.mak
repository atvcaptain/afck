# DISABLED = yes

HELP = build system sparse IMG Android-9

# We apply the mod only after the unpack mod
DEPS += $(STAMP.unpack)

define INSTALL
	cd $(BCT.DIR)system && ./build
	@echo -e " \nreplace old partition..."
	rm -f $(IMG.IN)system.PARTITION
	cp -v $(BCT.DIR)system/out/*.PARTITION $(IMG.IN) && sync
endef
