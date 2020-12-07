# UPDATE.ZIP build rules for flashing through Recovery mode
#
# Input variables:
# VARIANT - (optional) firmware option (4G, 3G, etc.)
# FIRMNAME - name of the firmware being formed (not the file name, only the name)
# UPD.PART - list of MMC partitions where the corresponding images are written to

# Check that all source data is set correctly
$(call ASSERT,$(FIRMNAME),Target firmware name must be set in the FIRMNAME variable!)
$(call ASSERT,$(PRODEV),The name of the device (ro.product.device) must be set in the PRODEV variable!)

# File name
UPD.ZIP = $(OUT)update-$(FIRMNAME)-$(VER)-$(DEVICE)$(if $(VARIANT),_$(VARIANT)).zip
# The end files from which the firmware is built
UPD.FILES = $(addprefix $(IMG.OUT),$(filter $(addsuffix .%,$(UPD.PART)),\
	$(IMG.COPY) $(IMG.BUILD) $(addsuffix .raw,$(IMG.EXT4))))

HELP.ALL += $(call HELPL,upd,Build UPDATE.ZIP for flashing through Recovery)

.PHONY: upd
upd: $(UPD.ZIP)

# Output firmware build rule
$(UPD.ZIP): $(UPD.FILES) | $(MOD.DEPS)
	tools/upd-maker -n "$(FIRMNAME) $(VER)" -d "$(PRODEV)" -o $@ $^

# The rule for unpacking sparse image into raw
%.PARTITION.raw: %.PARTITION
	$(TOOLS.DIR)simg2img $< $@
