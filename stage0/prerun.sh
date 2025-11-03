#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	# Install keyrings on HOST before bootstrap to ensure GPG signature validation
	apt-get -qq update
	apt-get -qq install -y --no-install-recommends debian-archive-keyring gnupg wget
	
	# Manually download and install Raspbian archive keyring GPG file
	if [ ! -f /usr/share/keyrings/raspbian-archive-keyring.gpg ]; then
		mkdir -p /usr/share/keyrings
		wget -q -O /usr/share/keyrings/raspbian-archive-keyring.gpg https://archive.raspbian.org/raspbian.public.key
		# Also import into the GPG keyring for debootstrap
		gpg --import --no-default-keyring --keyring /usr/share/keyrings/raspbian-archive-keyring.gpg /usr/share/keyrings/raspbian-archive-keyring.gpg 2>/dev/null || true
	fi
	
	# Use the Raspbian archive
	bootstrap ${RELEASE} "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/
fi
