#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
	echo "WARNING: RELEASE does not match the intended option for this branch."
	echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
	# Install debootstrap and keyring tooling on HOST before bootstrap
	apt-get -qq update
	apt-get -qq install -y --no-install-recommends \
		debootstrap \
		debian-archive-keyring \
		gnupg \
		wget \
		ca-certificates

	# Prepare Raspbian keyring (convert ASCII key to GPG keyring)
	RASPBIAN_KEYRING="/usr/share/keyrings/raspbian-archive-keyring.gpg"
	if [ ! -f "${RASPBIAN_KEYRING}" ]; then
		mkdir -p /usr/share/keyrings
		# download the public key and convert to a keyring usable by debootstrap/APT
		wget -q -O - https://archive.raspbian.org/raspbian.public.key | gpg --dearmor > "${RASPBIAN_KEYRING}"
		chmod 644 "${RASPBIAN_KEYRING}"
	fi

	echo "Bootstrapping Raspberry Pi OS base system..."

	# Correct debootstrap invocation:
	# options... <suite> <target> <mirror> (no extra 'bootstrap' token)
	# use --keyring and set --arch=armhf for Raspbian/armhf
	debootstrap --verbose --keyring="${RASPBIAN_KEYRING}" --arch=armhf "${RELEASE}" "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/
fi
