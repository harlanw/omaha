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

DIR=$PWD

export DIST_DIR="${DIR}/dist"
export PATCH_DIR="${DIR}/patches"
export CONFIGS_DIR="${DIR}/configs"

export UBOOT_GIT="https://github.com/u-boot/u-boot"
export UBOOT_BRANCH="v2018.09"
export UBOOT_DIR="${DIR}/u-boot"

export KERNEL_GIT="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
export KERNEL_BRANCH="linux-4.14.y"
export KERNEL_DIR="${DIR}/linux/src"

export FW_DIR="${DIR}/firmware"

export FW_BLOB_GIT="git://git.ti.com/processor-firmware/ti-linux-firmware.git"
export FW_BLOB_DIR="${FW_DIR}/blob"

export FW_PM_GIT="git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git"
export FW_PM_DIR="${FW_DIR}/pm"

export LINE="----------------------------------------------------"
