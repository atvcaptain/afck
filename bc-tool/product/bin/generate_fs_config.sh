#!/bin/sh
#
# Generate Android filesystem information for SHARP S2 vendor image.
#
if [ $# -lt 1 ]; then
	echo "Usage: $0 PRODUCT_DIR"
fi

PRODUCT_DIR=$1

#
# Generate wildcard default permissions:
# https://android.googlesource.com/platform/system/core/+/android-9.0.0_r30/libcutils/fs_config.cpp
#
{ \
	find $PRODUCT_DIR -type d -printf "product/%P 0 0 0755\n"; \
	find $PRODUCT_DIR -not -type d -printf "product/%P 0 0 0644\n"; \
} | sed -r "

	# Apply more specific defaults.

	s|^(product/etc/fs_config_files) .*|\1 0 0 0444|
	s|^(product/etc/fs_config_dirs) .*|\1 0 0 0444|
	s|^(product/lost+found) .*|\1 0 0 0700|
	s|^(product/build.prop) .*|\1 0 0 0600|
"
