#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	# Install keyrings on HOST before bootstrap to ensure GPG signature validation
	apt-get -qq update
	apt-get -qq install -y --no-install-recommends apt-key debian-archive-keyring gnupg wget
	
	# Manually download and install Raspbian archive keyring
	if [ ! -f /usr/share/keyrings/raspbian-archive-keyring.gpg ]; then
		wget -q -O /tmp/raspbian-archive-keyring.deb http://archive.raspbian.org/raspbian/pool/main/r/raspbian-archive-keyring/raspbian-archive-keyring_20120528.2_all.deb
		dpkg -i /tmp/raspbian-archive-keyring.deb
		rm -f /tmp/raspbian-archive-keyring.deb
	fi
	
	# Use the Raspbian archive
	bootstrap ${RELEASE} "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/
fi
