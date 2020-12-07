# Catalogue where the release comes together
DEPLOY.DIR = $(OUT)deploy/

HELP.ALL += $(call HELPL,deploy,Collect release in directory $(DEPLOY.DIR))

DEPLOY.FILES += $(addprefix $(DEPLOY.DIR),$(notdir $(DEPLOY)))

.PHONY: deploy
deploy: $(DEPLOY.FILES) | $(DEPLOY.DIR).stamp.dir

# In the simplest case, just move the files from $OUT to the release directory
$(DEPLOY.DIR)%: $(OUT)%
	$(call MV,$<,$@)
