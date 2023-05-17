#!/bin/sh -e

umount /mnt &> /dev/null || true

printf "Searching..."
while sleep 1; do
	printf "."
	[ ! -z "$(ifconfig | grep 192.168.6.1)" ] && break
done
echo " found!"

ssh debian@192.168.6.2
