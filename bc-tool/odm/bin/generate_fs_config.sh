#!/bin/sh
#
# Generate Android filesystem information for SHARP S2 vendor image.
#
if [ $# -lt 1 ]; then
	echo "Usage: $0 ODM_DIR"
fi

ODM_DIR=$1

#
# Generate wildcard default permissions:
# https://android.googlesource.com/platform/system/core/+/android-9.0.0_r30/libcutils/fs_config.cpp
#
{ \
	find $ODM_DIR -type d -printf "odm/%P 0 2000 0755\n"; \
	find $ODM_DIR -not -type d -printf "odm/%P 0 0 0644\n"; \
} | sed -r "

	# Apply more specific defaults.

	s|^(odm/etc/fs_config_files) .*|\1 0 0 0444|
	s|^(odm/etc/fs_config_dirs) .*|\1 0 0 0444|
"
