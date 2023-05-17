#!/bin/sh -e

KERNEL_DIR="linux/src"
export KERNEL_VERSION=$( cat "${KERNEL_DIR}/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
