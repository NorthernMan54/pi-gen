#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	# Install keyring packages on HOST before bootstrap to ensure GPG signature validation
	# These are needed by debootstrap which runs on the host, not in the target rootfs
	apt-get -qq update
	apt-get -qq install -y --no-install-recommends debian-archive-keyring raspbian-archive-keyring || true
	
	# Use the official Debian archive for Raspberry Pi OS with proper keyring
	bootstrap ${RELEASE} "${ROOTFS_DIR}" http://deb.debian.org/debian/
fi
