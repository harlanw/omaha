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

fetch_uboot () {
	local branch=$UBOOT_BRANCH

	if [ ! -d $UBOOT_DIR ]; then
		git clone $UBOOT_GIT $UBOOT_DIR
		git -C $UBOOT_DIR checkout $UBOOT_BRANCH -b "${UBOOT_BRANCH}-omaha"
		echo "Patching u-boot..."
		for patch in $PATCH_DIR/u-boot/*.patch; do
			[ -e "$patch" ] || continue
			echo "Applying $patch..."
			patch -p1 -d $UBOOT_DIR < $patch
		done

		echo "Copying u-boot config: ${CONFIGS_DIR}"
		cp "${CONFIGS_DIR}/u-boot.cfg" "${UBOOT_DIR}/.config"

		echo "Installed $UBOOT_BRANCH: $UBOOT_GIT"
	else
		branch=$(git -C $UBOOT_DIR branch | tail -n1 | sed 's/*\ //g')
	fi

	echo "Das U-Boot: $branch"
}

fetch_kernel () {
	local branch=$KERNEL_BRANCH

	if [ ! -d $KERNEL_DIR ] ; then
		git clone -b $KERNEL_BRANCH $KERNEL_GIT $KERNEL_DIR

		echo "Patching kernel..."
		for patch in $PATCH_DIR/kernel/*.patch; do
			[ -e "$patch" ] || continue
			echo "Applying $patch..."
			patch -p1 -d $KERNEL_DIR < $patch
		done

		echo "Copying kernel config: ${CONFIGS_DIR}"
		cp "${CONFIGS_DIR}/linux.cfg" "${KERNEL_DIR}/.config"

		echo "Installed $KERNEL_BRANCH sources: $KERNEL_GIT"
	else
		branch=$(git -C $KERNEL_DIR branch | sed 's/*\ //g')
	fi

	echo "Kernel: $branch"
}

fetch_firmware () {
	if [ ! -d $FW_PM_DIR ]; then
		git clone $FW_PM_GIT $FW_PM_DIR
	fi
	if [ ! -d $FW_BLOB_DIR ]; then
		git clone $FW_BLOB_GIT $FW_BLOB_DIR
	fi

	printf "Firmware: $branch"
	for fwdir in $FW_DIR/*; do
		[ -e "$fwdir" ] || continue
		local name=$(basename `git -C $fwdir remote get-url origin` | sed 's/.git//g')
		printf "$name "
	done
	printf '\n'
}

fetch_rootfs () {
	if [ ! -d "${DIR}/rootfs" ]; then
		# wget
		sudo cp ~/rootfs.tar .
		mkdir -p rootfs
		sudo tar xfvp rootfs.tar -C rootfs
		sudo rm rootfs.tar
	fi

	echo "rootfs: downloaded"
}

echo $LINE
echo "             Omaha Kernel Build Script"
. scripts/toolchain.sh
echo $LINE
fetch_uboot
echo $LINE
fetch_kernel
echo $LINE
fetch_firmware
echo $LINE
fetch_rootfs
echo $LINE
