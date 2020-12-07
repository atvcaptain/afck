# Firmware image assembly and disassembly rules for AMLogic chips
#
# Input variables:
# IMG.BASE - name of the base firmware file (the file must be in/)

# Check that all source data is set correctly
$(call ASSERT,$(IMG.BASE),The name of the file with basic firmware must be specified in the IMG.BASE variable!)

# Directory where the basic firmware is unpacked
IMG.IN = $(OUT)img-unpack/
# The directory where the final firmware components (boot, system, vendor, etc.) will be formed.
IMG.OUT = $(OUT)img-ubt/

HELP.ALL += $(call HELPL,help-img,Additional commands for working with images)
HELP.ALL += $(call HELPL,img-unpack,extract components from original image)

# Firmware configuration file for USB Burning Tool
UBT.CFG = $(TARGET.DIR)image.cfg
# List of UBT final firmware file components that are copied
# It is initially assumed that all components will be copied. As it is processed.
# recipes components can move from IMG.COPY to IMG.EXT4 (for ext4 images,
# that are parsed and then built back) and IMG.BUILD (for files that
# are somehow generated).
IMG.COPY = $(shell tools/aml-img-cfg "$(UBT.CFG)" files)

.PHONY: img-unpack
img-unpack: $(IMG.IN).stamp.unpack

# The stamp of unpacking the original image is put after unpacking the original image :)
$(IMG.IN).stamp.unpack: ingredients/$(IMG.BASE) $(IMG.IN).stamp.dir
	$(TOOLS.DIR)aml_image_v2_packer -d $< $(@D)
	$(call TOUCH,$@)

# The function is called for the base image component in ext4 format,
# that needs to be unpacked. If you call the function several times for
# of the same component, the function does nothing.
# Arguments:
# $1 is the name of the component to be unpacked (system, vendor, etc.)
#
# The function adds the necessary dependencies to the DEPS variable.
define IMG.UNPACK.EXT4
$(if $(filter $1.PARTITION,$(IMG.COPY)),$(eval $(call IMG.UNPACK.EXT4_,$1)))\
$(eval DEPS := $(DEPS) $(IMG.OUT).stamp.unpack-$1)
endef

define IMG.UNPACK.EXT4_
IMG.EXT4 := $$(IMG.EXT4) $$(filter $1.PARTITION,$$(IMG.COPY))
IMG.COPY := $$(filter-out $1.PARTITION,$$(IMG.COPY))

# The stamp of unpacking the original ext4 image depends on the partition image file
$$(IMG.OUT).stamp.unpack-$1: $$(IMG.IN)$1.PARTITION
	$$(call RMDIR,$$(IMG.OUT)$1)
	$$(call MKDIR,$$(IMG.OUT)$1)
	$$(call EXT4.UNPACK,$$<,$$(IMG.OUT)$1)
	$$(call TOUCH,$$(IMG.OUT)$1_contexts)
	$$(call TOUCH,$$@)

# The original ext4 image depends on the unpacking stamp of the original image
$$(IMG.IN)$1.PARTITION: $$(IMG.IN).stamp.unpack

HELP.IMG += $$(call HELPL,clean-img-$1,Clear unpacked image $1)
.PHONY: clean-img-$1
clean-img-$1:
	rm -f $$(IMG.OUT).stamp.unpack-$1 $$(IMG.OUT)$1_contexts
	rm -rf $$(IMG.OUT)$1
endef

# The function marks the firmware component as being built in mods.
# The rules of its creation are not generated for such components
# (by copying or collecting from "sprawl").
#
# $1 - name of the manually built component (_aml_dtb, bootlogo etc)
define IMG.WILL.BUILD
$(if $(filter $1.%,$(IMG.COPY)),$(eval $(call IMG.WILL.BUILD_,$1)))
endef

define IMG.WILL.BUILD_
IMG.BUILD := $$(IMG.BUILD) $$(filter $1.%,$$(IMG.COPY))
IMG.COPY := $$(filter-out $1.%,$$(IMG.COPY))
endef

.PHONY: help-img
help-img:
	@$(call SAY,$(C.SEP)$-$(C.RST)$(HELP.IMG))
	@$(call SAY,$(C.SEP)$-$(C.RST))
