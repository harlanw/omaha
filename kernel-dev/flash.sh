#!/bin/sh -e
#
# Copyright (c) 2018-2019 Harlan Waldrop <harlan@ieee.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

. scripts/config.sh
. scripts/version.sh

DISK="/dev/sdb"
MNT_DIR="/mnt"

write_bootloader () {
	dd if="/dev/zero" of="${DISK}" bs=1M count=10

	dd if="${UBOOT_DIR}/MLO" of="${DISK}" count=1 seek=1 bs=128k
	dd if="${UBOOT_DIR}/u-boot.img" of="${DISK}" count=2 seek=1 bs=384k

	sfdisk ${DISK} <<-__EOF__
	4M,,L,*
	__EOF__
}

write_filesystem () {
	# Build ext4 filesystem
	mkfs.ext4 -L rootfs "${DISK}1"

	# Copy root filesystem
	mount "${DISK}1" $MNT_DIR
	cp -p -v -r ./rootfs/. /mnt/. # TODO: Add buildscript for rootfs

	# Boot files
	mkdir -p "${MNT_DIR}/boot"
	cp "${DIST_DIR}/vmlinuz-${KERNEL_VERSION}" "${MNT_DIR}/boot/"
	echo "uname_r=${KERNEL_VERSION}" > "${MNT_DIR}/boot/uEnv.txt"

	mkdir -p "${MNT_DIR}/boot/dtbs/${KERNEL_VERSION}"
	cp $DIST_DIR/*.dtb "${MNT_DIR}/boot/dtbs/${KERNEL_VERSION}"

	# Modules
	tar xfv $DIST_DIR/*-modules.tar.xz -C $MNT_DIR

	# Firmware
	tar xfv $DIST_DIR/*-firmware.tar.xz -C $MNT_DIR
}

umount $MNT_DIR &> /dev/null || true

write_bootloader
write_filesystem
