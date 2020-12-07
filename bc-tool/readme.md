========================================
# bc-tool - unpack/repack  amlogic Android 9 images

========================================
* Special thanks:
* @a3sf6f - (Project base) https://github.com/a3sf6f/sharp_s2_system_image, https://github.com/a3sf6f/sharp_s2_treble_vendor_image 
* @anpaza - afck (Android Firmware Construction Kit), https://github.com/anpaza/afck 
* @rkhat2 - sefcontext_compile, https://github.com/rkhat2/android-rom-repacker/tree/android-9
* @tytso - e2fsprogs, https://github.com/tytso/e2fsprogs
========================================

What is needed
----------------------------------------
- OS Ubuntu ≥ 18.04 / 64bit
- android-tools-fsutils
- device-tree-compiler (DTC)

# if not installed, install it

~$ sudo apt install android-tools-fsutils
~$ sudo apt install device-tree-compiler
=========================================
# HOW TO USE
export MAKEFLAGS='--no-print-directory'

cd ~/afck
-----------------------------------------
- Call up list of available MOD's

make help-mod
-----------------------------------------
- Always start with

make mod-unpack
-----------------------------------------
- Edit your partition / partitions and build them back into a sparse IMG (*.PARTITION)
- Select and start the desired MOD, e.g.

# if you have modified only a single partition, e.g. system, use:
make mod-system

# if you have made changes to several partitions at the same time, e.g. system, vendor, product etc., use:
make mod-partition-all

# ATTENTION:
If you have to make changes to selinux files (*.cil), please note that INIT makes a preliminary check of the sha256-sum - If the sha256-sum of all *.cil files used to compile precompiled_sepolicy binary matches, the precompiled_sepolicy binary is loaded and INIT Process continues. If the sha256-sum does NOT match, the INIT process is interrupted, which in most cases leads to a boot loop, reboot to recovery or bootloader.
For this reason, I have installed a preliminary check of the extracted/modified *.cil files, if the sha256-sum does NOT match, the compilation process of a partition is interrupted and you are informed that "mod-sepolicy" is carried out. 
- Now do this step:

make mod-sepolicy
-----------------------------------------
- Build an installation IMG, aml_upgrade_package.img for ABT / sdc_burn

make mod-IMG
-----------------------------------------
- Cleanup bc-tool directory (There are two options for this)

1. cleanup build directory (all extracted/already modified files and folders in the bc-tool directory will be deleted. The "out" folder of the respective partition is also deleted at the start of the build process by the build script instruction, this is an overwrite protection in case you forget to execute "make cleanup" ;))
2. cleanup output directory only (Delete out/aml_upgrade_package.img in bc-tool directory)
3. cleanup bc-tool/stamp directory (to be able to execute the same MODs repeatedly, you need to execute this function)

make bc-clean
------------------------------------------
- Cleanup img-unpack directory

make clean
------------------------------------------
# Build directory
bc-tool/

# Target directories
out/amlogic/device/1-2g/img-unpack/(extracted aml_package_upgrade.img files)
bc-tool/out/aml_upgrade_package.img
bc-tool/system/out/system.PARTITION
bc-tool/vendor/out/vendor.PARTITION
bc-tool/product/out/product.PARTITION
bc-tool/odm/out/odm.PARTITION
bc-tool/stamp/.stamp.mod* files
------------------------------------------
# NOTE:
Generated timestamp files are used to protect against repeated overwriting of the files.
If you want to use a MOD repeatedly, you must delete the respective .stamp.mod* file in the bc-tool/stamp, but please note that the previously executed MOD will be overwritten (use "bc-clean" for this, see above)
------------------------------------------
# Android 8 only
If you want to modify and build Android 8 images, you have to set the afck tool to default settings. 
Make the following changes in GNUmake and mod.mak files:

# GNUmake file changes
TARGET = x96max/beelink
# TARGET = amlogic/device
# include bc-tool/clean-up.mak

# build/mod.mak file changes
STAMP := $$(IMG.OUT).stamp.mod-$$(MOD)
# STAMP := $$(STAMP.DIR).stamp.mod-$$(MOD)
------------------------------------------
# If you want to use your own project binary, just compile it e.g.

~$ cd patch/to-your/sdk
~$ . build/envsetup.sh
~$ lunch your-device
~$ godir e2fsdroid
~$ mma

