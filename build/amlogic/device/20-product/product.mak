# DISABLED = yes

HELP = build product sparse IMG Android-9

# We apply the mod only after the unpack mod
DEPS += $(STAMP.unpack)

define INSTALL
	cd $(BCT.DIR)product && ./build
	@echo -e " \nreplace old partition..."
	rm -f $(IMG.IN)product.PARTITION
	cp -v $(BCT.DIR)product/out/*.PARTITION $(IMG.IN) && sync
endef
