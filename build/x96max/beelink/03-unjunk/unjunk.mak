HELP = Garbage Cleaning Beelink firmware

$(call IMG.UNPACK.EXT4,system)
$(call IMG.UNPACK.EXT4,vendor)

# Clarification on removing APKs:
# AppMarket some non-working shit
# * Music a.k.a. Bee Music a.k.a. "Do you want to go out the player?" -> "Oh yes!"
# CompanionDeviceManager non-working shit
# (am start-activity -a android.companiondevice.START_DISCOVERY
# -> in the application com.android.companiondevicemanager there was a failure).
# * FileManager famous "bee files", in the representation does not need
# WAPPushManager - something about WAP, we do not have a phone
# FotaUpdate # - the update will end badly for the user
# * NativeImagePlayer - scary picture viewer
# * FileBrowser - replaced by Total Commander
# * AppInstaller - replaced by XAPK Installer
define INSTALL
	tools/sed-patch -e '/preinstall Apks/$(COMMA)/^$$/d' \
		-e '/^.HDMI IN/$(COMMA)/^$$/d' \
		$/vendor/etc/init/hw/init.amlogic.board.rc
	rm -f $/system/bin/preinstallApks.sh 
	rm -rf $/system/usr/trigtop
	rm -rf $(addprefix $/system/app/,AppMarket BeeMusic Music \
		CompanionDeviceManager FileManager \
		WAPPushManager FotaUpdate FotaUpdateReboot)
	rm -rf $(addprefix $/vendor/app/,OTAUpgrade NativeImagePlayer \
		FileBrowser AppInstaller)
endef

define DESC
Unwanted applications removed from the firmware AppMarket, BeeMusic, Music,
CompanionDeviceManager, FileManager, WAPPushManager, FotaUpdate,
FotaUpdateReboot, OTAUpgrade, NativeImagePlayer, FileBrowser,
AppInstaller.
endef
