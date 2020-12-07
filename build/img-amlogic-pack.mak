# Firmware image assembly rules for USB Burning Tool
#
# Input variables:
# VARIANT - (optional) firmware option (4G, 3G, etc.)
# FIRMNAME - name of the firmware being formed (not the file name, only the name)

# Check that all source data is set correctly
$(call ASSERT,$(FIRMNAME),Target firmware name must be set in the FIRMNAME variable!)

# Generated image for USB Burning Tool
UBT.IMG = $(OUT)$(FIRMNAME)-$(VER)-$(DEVICE)$(if $(VARIANT),_$(VARIANT)).img
# The end files from which the firmware is built
UBT.FILES = $(addprefix $(IMG.OUT),$(IMG.COPY) $(IMG.EXT4) $(IMG.BUILD))

HELP.ALL += $(call HELPL,ubt,Build firmware in AmLogic USB Burning Tool format)
HELP.ALL += $(call HELPL,help-ubt,display a list of separately assembled components for UBT)

HELP.UBT += $(call HELPL,ubt-img,Collect all images$(COMMA) from which the firmware is collected)

.PHONY: ubt ubt-img
ubt: $(UBT.IMG)
ubt-img: $(UBT.FILES)

# Output firmware build rule
$(UBT.IMG): $(UBT.CFG) $(UBT.FILES)
	$(TOOLS.DIR)aml_image_v2_packer -r $< $(IMG.OUT) $@

# To make images of partitions, you must first overlay the mods
$(UBT.FILES): $(MOD.DEPS)

# Rules for firmware files that do not require modification (direct copy)
#1 - file name of the firmware component
# $2 - (optionally) the name of the component source file
define IMG.PACK.COPY
# The file in the output directory depends on the file in the input directory
$$(IMG.OUT)$1: $$(if $2,$2,$$(IMG.IN)$1)
	$$(call CP,$$<,$$@)

# The presence of a file in the input directory depends on the unpacking stamp of the original image
$$(IMG.IN)$1: $$(IMG.IN).stamp.unpack

endef

# Rules for building the ext4 image
define IMG.PACK.EXT4
.PHONY: ubt-$(basename $1)
ubt-$(basename $1): $$(IMG.OUT)$1
HELP.UBT += $$(call HELPL,ubt-$(basename $1),Collect $$(IMG.OUT)$1)

# To get the final ext4 image, you need to pack the unpacked image
$$(IMG.OUT)$1: $$(IMG.OUT)$(basename $1)_contexts.all $$(IMG.OUT).stamp.unpack-$(basename $1)
	$$(TOOLS.DIR)ext4pack -d $$(IMG.OUT)$(basename $1) -o $$@ -c $$< \
	$$(if $$(EXT4.SIZE.$(basename $1)),-s $$(EXT4.SIZE.$(basename $1)),-O $$(IMG.IN)$1)

$$(IMG.OUT)$(basename $1)_contexts.all: $$(FILE_CONTEXTS.$(basename $1))
	tools/merge-contexts $$^ >$$@

$$(FILE_CONTEXTS.$(basename $1)): $$(IMG.OUT).stamp.unpack-$(basename $1) $(MOD.DEPS)

endef

# Files from IMG.COPY are directly copied from the original unpacked image
$(foreach _,$(IMG.COPY),$(eval $(call IMG.PACK.COPY,$_)))
# Files from IMG.EXT4 are packed from the unpacked directory
$(foreach _,$(IMG.EXT4),$(eval $(call IMG.PACK.EXT4,$_)))
# Files from IMG.BUILD are collected by the rules in the mods themselves

.PHONY: help-ubt
help-ubt:
	@$(call SAY,$(C.SEP)$-$(C.RST)$(HELP.UBT))
	@$(call SAY,$(C.SEP)$-$(C.RST))
