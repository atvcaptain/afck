# DISABLED = yes

HELP = build odm product vendor system sparse IMG Android 9

# We apply the mod only after the unpack mod
DEPS += $(STAMP.mod-unpack)

define INSTALL
	cd $(BCT.DIR)odm && ./build
	@echo ""
	cd $(BCT.DIR)product && ./build
	@echo ""
	cd $(BCT.DIR)vendor && ./build
	@echo ""
	cd $(BCT.DIR)system && ./build
	@echo -e " \nreplace old partitions"
	rm -f $(IMG.IN)odm.PARTITION product.PARTITION vendor.PARTITION system.PARTITION
	cp -v $(BCT.DIR)odm/out/*.PARTITION $(IMG.IN) && sync
	cp -v $(BCT.DIR)product/out/*.PARTITION $(IMG.IN) && sync
	cp -v $(BCT.DIR)vendor/out/*.PARTITION $(IMG.IN) && sync
	cp -v $(BCT.DIR)system/out/*.PARTITION $(IMG.IN) && sync
endef
