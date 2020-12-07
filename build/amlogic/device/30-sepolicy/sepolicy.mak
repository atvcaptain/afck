# DISABLED = yes

HELP = compile sepolicy

# We apply the mod only after the unpack mod
# DEPS += $(STAMP.mod-unpack)

define INSTALL
	cd $(BCT.DIR) && ./compile_sepolicy
endef
