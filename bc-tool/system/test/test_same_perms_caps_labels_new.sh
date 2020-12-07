#!/bin/sh
#
# Test a repacked image which should preserve all the permissions, modes, labels and capabilities
# from within the stock 9.0 /system partition.
#
# For those newly added files that are not in the stock system will simply be ignored.
#

if [ $# -lt 1 ]; then
	echo "Usage: $0 SPARSE_SYSTEM_IMAGE"
	exit
fi

SYSTEM_IMAGE=$(readlink -f $1)

SIMG2IMG=simg2img
STOCK_FS=fs_config_new.txt

script_root=$(dirname $(readlink -f $0))
tmp_name=`basename -s .sparseimg $SYSTEM_IMAGE`
tmp_mnt=$tmp_name
tmp_img=$tmp_name.img
tmp_img_fs=$tmp_name.fs_config.txt

cd $script_root
mkdir -p $tmp_mnt
echo "convert to unsparse..."
$SIMG2IMG $SYSTEM_IMAGE $tmp_img

echo "mount unsparseimg..."
sudo mount -t ext4 -o ro,loop $tmp_img $tmp_mnt
sudo ../bin/dump_android_filesystem.sh $tmp_mnt > $tmp_img_fs
echo "dump filesystem..."
sudo umount $tmp_mnt

rm $tmp_img
rmdir $tmp_mnt

compare=`diff $tmp_img_fs $STOCK_FS | grep ">"`
if [ "$compare" != "" ]; then
	echo "failed"
	echo "failed fs_config for repacked image is at $(readlink -f $tmp_img_fs)"
	exit 1
fi
echo "test OK!"
rm $tmp_img_fs
