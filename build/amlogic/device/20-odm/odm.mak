# DISABLED = yes

HELP = build odm sparse IMG Android-9

# We apply the mod only after the unpack mod
DEPS += $(STAMP.unpack)

define INSTALL	 
	cd $(BCT.DIR)odm && ./build
	@echo "replace old partition..."
	rm -f $(IMG.IN)odm.PARTITION
	cp -v $(BCT.DIR)odm/out/*.PARTITION $(IMG.IN) && sync
endef
