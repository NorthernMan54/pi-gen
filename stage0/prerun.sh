#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	# Install keyrings on HOST before bootstrap to ensure GPG signature validation
	apt-get -qq update
	apt-get -qq install -y --no-install-recommends debian-archive-keyring gnupg wget ca-certificates
	
	# Manually download and install Raspbian archive keyring GPG file
	RASPBIAN_KEYRING="/usr/share/keyrings/raspbian-archive-keyring.gpg"
	if [ ! -f "${RASPBIAN_KEYRING}" ]; then
		mkdir -p /usr/share/keyrings
		# Download the public key and convert to GPG keyring format
		wget -q -O - https://archive.raspbian.org/raspbian.public.key | gpg --dearmor > "${RASPBIAN_KEYRING}"
	fi
	
	echo "Bootstrapping Raspberry Pi OS base system..."

	echo "/usr/share/debootstrap bootstrap ${RELEASE} \"${ROOTFS_DIR}\" http://raspbian.raspberrypi.com/raspbian/ --keyring=\"${RASPBIAN_KEYRING}\""

	# Use the Raspbian archive with explicit keyring
	debootstrap --verbose bootstrap ${RELEASE} "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/ --keyring="${RASPBIAN_KEYRING}"
fi
