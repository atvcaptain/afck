#!/bin/sh
#
# Generate Android filesystem information
#
if [ $# -lt 1 ]; then
	echo "Usage: $0 SYSTEM_DIR"
fi

SYSTEM_DIR=$1

#
# Generate wildcard default permissions:
# https://android.googlesource.com/platform/system/core/+/refs/tags/android-9.0.0_r39/libcutils/fs_config.cpp
# https://android.googlesource.com/platform/system/core/+/refs/tags/android-10.0.0_r32/libcutils/fs_config.cpp
#
{ \
	find $SYSTEM_DIR -type d -printf "%P 0 0 0755\n"; \
	find $SYSTEM_DIR -not -type d -printf "%P 0 0 0644\n"; \
} | sed -r "
	s|^(cache) .*|\1 1000 2001 0770|
	s|^(data) .*|\1 1000 1000 0771|
	s|^(apex) .*|\1 0 2000 0755|
	s|^(mnt) .*|\1 0 1000 0755|
	s|^(root) .*|\1 0 0 0755|
	s|^(sbin) .*|\1 0 2000 0750|
	s|^(sdcard) .*|\1 0 0 0777|
	s|^(storage) .*|\1 0 1028 0751|
	s|^(sec_storage) .*|\1 0 1028 0751|
	s|^(system/bin) .*|\1 0 2000 0755|
	s|^(system/etc/ppp) .*|\1 0 0 0755|
	s|^(system/xbin) .*|\1 0 2000 0755|
	s|^(system/apex) .*|\1 0 2000 0755|
	s|^(vendor) .*|\1 0 2000 0755|

	s|^(lost+found) .*|\1 0 0 0700|
	s|^(bin/[^ ]+) .*|\1 0 0 0755|
	s|^(sbin/[^ ]+) .*|\1 0 2000 0750|
	s|^(init[^ ]*) .*|\1 0 2000 0750|
	s|^(system/bin/[^ ]+) .*|\1 0 2000 0755|
	s|^(system/xbin/[^ ]+) .*|\1 0 2000 0755|
	s|^(system/apex/[^ ]+) .*|\1 0 2000 0755|

	s|^(default.prop) .*|\1 0 0 0600|
	s|^(system/etc/prop.default) .*|\1 0 0 0600|
	s|^(system/bin/crash_dump32) .*|\1 0 2000 0755|
	s|^(system/bin/crash_dump64) .*|\1 0 2000 0755|
	s|^(system/bin/install-recovery.sh) .*|\1 0 0 0750|
	s|^(system/bin/debuggerd) .*|\1 0 2000 0755|
	s|^(system/bin/secilc) .*|\1 0 0 0700|
	s|^(system/bin/uncrypt) .*|\1 0 0 0750|
	s|^(system/build.prop) .*|\1 0 0 0600|
	s|^(system/etc/fs_config_dirs) .*|\1 0 0 0444|
	s|^(system/etc/fs_config_files) .*|\1 0 0 0444|
	s|^(system/etc/ppp/[^ ]+) .*|\1 0 0 0555|

	s|^(system/bin/logd) .*|\1 1036 1036 0550 capabilities=0x440000040|
	s|^(system/bin/bootstat) .*|\1 1000 1007 0550 capabilities=0x400000000|
	s|^(system/bin/run-as) .*|\1 0 2000 0750 capabilities=0xc0|
	s|^(system/bin/surfaceflinger) .*|\1 1000 1003 0755 capabilities=0x800000|

	# Apply vendor-specific permissions and capabilities.

	s|^(config) .*|\1 0 0 0555|
	s|^(system/xbin/procmem) .*|\1 0 0 06755|
	s|^(system/xbin/su) .*|\1 0 2000 06755|
"
# s|^(system/xbin/su) .*|\1 0 2000 04750|
