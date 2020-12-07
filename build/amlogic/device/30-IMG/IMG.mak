# DISABLED = yes

HELP = create $(IMG.BASE) Android-9

define INSTALL
	mkdir -p $(BCT.DIR)out
	$(TOOLS.DIR)aml_image_v2_packer -r $(IMG.IN)/image.cfg $(IMG.IN) $(BCT.DIR)out/${IMG.BASE}
	@echo -e " \n\033[32mdone!\033[0m"
endef
