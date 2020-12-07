# Rules for tracking the firmware version number

# The current version number can be found in the subdirectory of the target platform
include $(TARGET.DIR)/img-version.mak

# Forming the full version number
VER = $(strip $(VER.HI)).$(strip $(VER.LO)).$(strip $(VER.REV)).

HELP.HDR += Firmware: $(C.BOLD)$(FIRMNAME)$(C.RST) version: $(C.BOLD)$(VER)$(C.RST)$(NL)
HELP.ALL += $(call HELPL,help-ver,Targets for manipulation with version number)

HELP.VER += $(call HELPL,ver_next_hi,Increase the older version number ($(VER.HI) -> $(call ADD,$(VER.HI),1)))
HELP.VER += $(call HELPL,ver_next_lo,Increase the lower version number ($(VER.LO) -> $(call ADD,$(VER.LO),1)))
HELP.VER += $(call HELPL,ver_next_rev,Increase revision number ($(VER.REV) -> $(call ADD,$(VER.REV),1)))

VER.UPDATE = $(call FWRITE,$(TARGET.DIR)/img-version.mak,VER.HI=$1$(NL)VER.LO=$2$(NL)VER.REV=$3)

.PHONY: ver_show ver_next_rev ver_next_lo ver_next_hi
ver_show:
	@$(call SAY,Target image version: $(C.BOLD)$(VER)$(C.RST))
ver_next_rev:
	$(call VER.UPDATE,$(VER.HI),$(VER.LO),$(call ADD,$(VER.REV),1))
	@$(MAKE) --no-print-directory ver_show
ver_next_lo:
	$(call VER.UPDATE,$(VER.HI),$(call ADD,$(VER.LO),1),0)
	@$(MAKE) --no-print-directory ver_show
ver_next_hi:
	$(call VER.UPDATE,$(call ADD,$(VER.HI),1),0,0)
	@$(MAKE) --no-print-directory ver_show

.PHONY: help-ver
help-ver:
	@$(call SAY,$(C.SEP)$-$(C.RST)$(HELP.VER))
	@$(call SAY,$(C.SEP)$-$(C.RST))
