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

GCC_HOST="x86_64"
GCC_DIR="${DIR}/toolchain"

SILENT=false

detect_toolchain () {
	local site="https://releases.linaro.org"
	local major="7"
	local minor="3"
	local micro="1"
	local release="2018.05"

	gcc_target="arm-linux-gnueabihf"
	gcc_filename="gcc-linaro-${major}.${minor}.${micro}-${release}-${GCC_HOST}_${gcc_target}"
	gcc_url="${site}/components/toolchain/binaries/${major}.${minor}-${release}/${gcc_target}/${gcc_filename}.tar.xz"

	if which "${gcc_target}-gcc" &> /dev/null; then
		gcc_path=$gcc_target
		export CC="${gcc_target}-"
	elif [ ! -d "${GCC_DIR}" ] ; then
		fetch_toolchain
		gcc_path="${GCC_DIR}/${gcc_filename}/bin"
		export CC="${gcc_path}/${gcc_target}-"
	else
		gcc_path="${GCC_DIR}/${gcc_filename}/bin"
		export CC="${gcc_path}/${gcc_target}-"
	fi

	if [ "$SILENT" = false ]; then
		echo "ARM Toolchain: $gcc_target"
	fi
}

fetch_toolchain () {
	wget -c --directory-prefix="${GCC_DIR}" "${gcc_url}"
	tar -xf "${GCC_DIR}/${gcc_filename}.tar.xz" -C "${GCC_DIR}/"

	if [ "$SILENT" = false ]; then
		echo "${gcc_url}"
	fi
}

if [ "$1" != "--silent" ]; then
	SILENT=true
fi

detect_toolchain $1
