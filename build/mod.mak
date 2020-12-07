HELP.ALL += $(call HELPL,mod,Execute all image modification recipes)
HELP.ALL += $(call HELPL,help-mod,Targets to apply individual modifications to the firmware)

# The function downloads a fashion recipe from a .mak file.
# The result of the function is code for Make, which is then interpreted by
# with the eval function. This is why the function works in two stages: the first stage
# is composed *text*, at the second stage this text is interpreted as *code*.
# In the disclosures to be postponed to the second stage, you should use
# double dollar sign $$(), so that in the first step it becomes a normal
# disclosure $(), and already in the second stage the disclosure actually happened.
define MOD.INCLUDE
# Zero the variables that set the mods
# Fashion description line
HELP :=
# Commands to set the fashion
INSTALL :=
# By default, the module is enabled
DISABLED :=
# Multi-line fashion description for the README file
DESC :=

# The name of the target is calculated by the directory name
MOD := $$(basename $$(notdir $1))
# The DIR variable contains the path to the fashion catalog
DIR := $$(dir $1)
# Fashion Readiness Stamp File
# STAMP := $$(IMG.OUT).stamp.mod-$$(MOD)
STAMP := $$(STAMPDIR).stamp.mod-$$(MOD)
# Files on which fashion depends
DEPS := $$(wildcard $$(DIR)*)
# For simplicity, the base directory where partitions are unpacked
/ := $$(IMG.OUT)

include $1

ifeq ($$(DISABLED),)
$$(call ASSERT,$$(INSTALL),$$(MOD): You must define the commands in the INSTALL variable,)
HELP.MOD := $$(HELP.MOD)$$(call HELPL,mod-$$(MOD),$$(HELP))

INSTALL.mod-$$(MOD) := $$(INSTALL)
STAMP.mod-$$(MOD) := $$(STAMP)
HELP.mod-$$(MOD) := $$(HELP)
DESC.mod-$$(MOD) := $$(DESC)

.PHONY: mod-$$(MOD)
mod-$$(MOD): $$(STAMP.mod-$$(MOD))

# Variables defined above cannot be used in commands,
# because they are interpreted directly during eval.
$$(STAMP.mod-$$(MOD)): $$(DEPS)
	$$(call MKDIR,$$(@D))
	$$(INSTALL.mod-$(basename $(notdir $1)))
	$$(call TOUCH,$$@)

MOD.DEPS := $$(MOD.DEPS) $$(STAMP.mod-$$(MOD))
MOD.ALL := $$(MOD.ALL) $$(MOD)
endif
endef


# Download all the recipes (patches, additions, etc.) that are available for our platform
$(foreach _,$(sort $(wildcard $(TARGET.DIR)*/*.mak)),$(eval $(call MOD.INCLUDE,$_)))

.PHONY: mod help-mod mod-help mod-doc
mod: $(MOD.DEPS)

help-mod mod-help:
	@$(call SAY,$(C.SEP)$-$(C.RST)$(HELP.MOD))
	@$(call SAY,$(C.SEP)$-$(C.RST))

show-rules:
	$(call SAY,$(foreach _,$(sort $(wildcard $(TARGET.DIR)*/*.mak)),$(call MOD.INCLUDE,$_)$(NL)))

MOD.DOC = $(OUT)$(FIRMNAME)-$(VER)-$(DEVICE)$(if $(VARIANT),_$(VARIANT)).md
DEPLOY += $(MOD.DOC)
mod-doc: $(MOD.DOC)

MOD.DOC.MAKE = $(foreach _,$(MOD.ALL),$(call MOD.DOC.MAKE_,$_))
define MOD.DOC.MAKE_

* $_ - $(HELP.mod-$1)
$(if $(DESC.mod-$1),  $(DESC.mod-$1))
endef

# Replacing special tags with variable values in documentations
MOD.SEDREPL = -e 's/@FIRMNAME@/$(FIRMNAME)/g' \
	      -e 's/@VER@/$(VER)/g' \
	      -e 's/@DEVICE@/$(DEVICE)/g' \
	      -e 's/@VARIANT@/$(VARIANT)/g'

$(MOD.DOC): $(MAKEFILE_LIST)
	sed $(TARGET.DIR)/README-head.md $(MOD.SEDREPL) >$@
	@$(call SAY,$(call MOD.DOC.MAKE)) | sed $(MOD.SEDREPL) >>$@
	sed $(TARGET.DIR)/README-tail.md $(MOD.SEDREPL) >>$@

