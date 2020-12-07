.PHONY: help clean

HELP.HDR :=
HELP.ALL :=

HELP.HDR += Базисная ОС: $(C.BOLD)$(HOST.OS)$(C.RST), dedicated platform: $(C.BOLD)$(TARGET)$(C.RST)$(NL)
HELP.ALL += $(call HELPL,clean,Delete all generated files)

# Output the help text
help:
	@$(call SAY,$(C.SEP)$-$(C.RST))
	@$(call SAY,$(HELP.HDR))
	@$(call SAY,$(C.HEAD)Select the target to build:$(C.RST))
	@$(call SAY,$(C.SEP)$-$(C.RST)$(HELP.ALL))
	@$(call SAY,$(C.SEP)$-$(C.RST))

# Complete cleaning of the directory with the created files
clean:
	$(call RMDIR,$(OUT))

# A rule to create a directory stamp file.
# A directory stamp is used to prevent undesirable rebuilds
# of dependent purposes, because when creating files in the directory its time stamp is
# the last modification also changes, so we cannot depend on
# directly from the directory itself.
%/.stamp.dir:
	$(call MKDIR,$(@D))
	$(call TOUCH,$@)
