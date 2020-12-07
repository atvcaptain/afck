# Firmware name
FIRMNAME = atv-9
# Target device name (no spaces)
DEVICE = s905x
# Firmware variant, default value
VARIANT ?= 1-2g
# Hardware platform name (ro.product.device)
PRODEV = p212
# Base firmware file name
IMG.BASE = aml_upgrade_package.img
# In eMMC, under /dev/block/vendor, 256Mb is allocated and the FS image is only 256Mb
EXT4.SIZE.vendor=335544320

# Preferred architecture for libraries in installed APKs
# (through space in order of priority reduction)
APKARCH=armeabi-v7a armeabi

# Add a suffix to the OUT directory depending on the firmware version
OUT := $(OUT)$(VARIANT)/

# Rules to calculate version number
include build/version.mak

# Add the rules for unpacking the source image
include build/img-amlogic-unpack.mak

# SELinux contexts for each of the ext4 partitions
FILE_CONTEXTS.vendor = $(IMG.OUT)system/system/etc/selinux/plat_file_contexts \
	$(IMG.OUT)vendor/etc/selinux/vendor_file_contexts \
	$(IMG.OUT)vendor_contexts
FILE_CONTEXTS.system = $(IMG.OUT)system/system/etc/selinux/plat_file_contexts \
	$(IMG.OUT)vendor/etc/selinux/vendor_file_contexts \
	$(IMG.OUT)system_contexts

# For these files to exist, the corresponding ext4 image must be unpacked.
FILE_CONTEXTS.DEP += $(IMG.OUT).stamp.unpack-system $(IMG.OUT).stamp.unpack-vendor $(IMG.OUT).stamp.unpack-odm $(IMG.OUT).stamp.unpack-product

# Now the rules for superimposing modifications
include build/mod.mak

# Final image packaging rules
include build/img-amlogic-pack.mak

# We also want an image for flashing through Recovery
UPD.PART = odm product vendor system boot _aml_dtb
include build/recovery-pack.mak

# A list of files that make it to release
DEPLOY = $(UBT.IMG) $(UPD.ZIP)

# Rules to build the release
include build/deploy.mak
