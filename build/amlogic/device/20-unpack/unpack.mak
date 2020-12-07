# DISABLED = yes

HELP = unpack partitions Android-9

DEPS += $(STAMP.mod-cleanup)

$(call IMG.UNPACK.EXT4,odm) $(call IMG.UNPACK.EXT4,product)
$(call IMG.UNPACK.EXT4,system) $(call IMG.UNPACK.EXT4,vendor)

# define environment varriables for build process
export MKE2FS_CONFIG += /SSD2/afck/$(BCT.DIR)mke2fs.conf

define INSTALL
	$(TOOLS.DIR)ext4unpack $(IMG.IN)odm.PARTITION $(ODM)
	$(TOOLS.DIR)ext4unpack $(IMG.IN)vendor.PARTITION $(VENDOR)
	$(TOOLS.DIR)ext4unpack $(IMG.IN)product.PARTITION $(PRODUCT)
	$(TOOLS.DIR)ext4unpack $(IMG.IN)system.PARTITION $(SYSTEM)
			cp $(IMG.IN)_aml* $(BCT.DIR)DTB && sync
			cp -v $(VENDOR)/etc/selinux/*file_contexts $(O.SELINUX)
			cp -v $(VENDOR)/etc/selinux/*file_contexts $(P.SELINUX)
			cp -v $(VENDOR)/etc/selinux/*file_contexts $(V.SELINUX)
			cp -v $(VENDOR)/etc/selinux/*file_contexts $(S.SELINUX)
			cp -v $(SYSTEM)/system/etc/selinux/*file_contexts $(O.SELINUX)
			cp -v $(SYSTEM)/system/etc/selinux/*file_contexts $(P.SELINUX)
			cp -v $(SYSTEM)/system/etc/selinux/*file_contexts $(V.SELINUX)
			cp -v $(SYSTEM)/system/etc/selinux/*file_contexts $(S.SELINUX)
			rm -rf $(IMG.OUT)*
	@echo -e " \n\033[32munpack done!\033[0m"
endef

define DESC
* This modification extracts a sparse IMG
* into the specified directory
endef
