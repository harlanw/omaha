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

. scripts/toolchain.sh --silent
. scripts/config.sh
. scripts/version.sh

MKFLAGS="-j2 ARCH=arm CROSS_COMPILE=$CC"
UBOOT_MKFLAGS="-C $UBOOT_DIR $MKFLAGS"
KERNEL_MKFLAGS="-C $KERNEL_DIR $MKFLAGS"
FW_PM_MKFLAGS="-C $FW_PM_DIR $MKFLAGS"

build_uboot () {
	if [ "$OPT_NEW" = true ]; then
		make $UBOOT_MKFLAGS am335x_evm_defconfig
	fi
	if [ "$OPT_MENU" = true ]; then
		make $UBOOT_MKFLAGS menuconfig
	fi

	make $UBOOT_MKFLAGS
	{
		tar cfJ "${DIST_DIR}/omaha-${KERNEL_VERSION}-uboot.tar.xz" -C "${UBOOT_DIR}" "MLO" -C "${UBOOT_DIR}" "u-boot.img"
	}
}

build_kernel () {
	if [ "$OPT_MENU" = true ]; then
		make $KERNEL_MKFLAGS menuconfig
	fi

	# Kernel
	make $KERNEL_MKFLAGS zImage
	{
		# FIXME: Improve this
		. scripts/version.sh
		cp -v "${KERNEL_DIR}/arch/arm/boot/zImage" "${DIST_DIR}/vmlinuz-${KERNEL_VERSION}"
	}

	# Modules
	make $KERNEL_MKFLAGS modules
	{
		local tmp="${DIST_DIR}/tmp/"
		make $KERNEL_MKFLAGS modules_install INSTALL_MOD_PATH=$tmp
		tar cfJ "${DIST_DIR}/omaha-${KERNEL_VERSION}-modules.tar.xz" -C $tmp .
		rm -rf $tmp
	}

	# Device Tree
	make $KERNEL_MKFLAGS am335x-pocketbeagle.dtb
	cp -v "${KERNEL_DIR}/arch/arm/boot/dts/am335x-pocketbeagle.dtb" "${DIST_DIR}/"
}

build_firmware () {
	local dir="lib/firmware"

	make $FW_PM_MKFLAGS
	tar cfJ "${DIST_DIR}/omaha-${KERNEL_VERSION}-firmware.tar.xz" \
		--transform 's,^,lib/firmware/,' \
		-C "${FW_PM_DIR}/bin/" "am335x-pm-firmware.elf"

	# Firmware blobs intentionally omited
}

if [ "$1" = "--menu" ]; then
	OPT_MENU=true
fi

mkdir -p $DIST_DIR

build_kernel
build_uboot
build_firmware
