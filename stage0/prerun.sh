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
		ca-certificates \
		binutils

	# Prepare Raspbian keyring from official package (contains SHA256 signatures)
	RASPBIAN_KEYRING="/usr/share/keyrings/raspbian-archive-keyring.gpg"
	if [ ! -f "${RASPBIAN_KEYRING}" ]; then
		mkdir -p /usr/share/keyrings
		
		echo "Downloading official raspbian-archive-keyring package..."
		RASPBIAN_POOL_URL="http://archive.raspbian.org/raspbian/pool/main/r/raspbian-archive-keyring"
		
		# Get the latest version
		LATEST_DEB=$(wget -q -O - "$RASPBIAN_POOL_URL/" | grep -oP 'raspbian-archive-keyring_[^"]+_all\.deb' | sort -V | tail -1)
		
		if [ -z "$LATEST_DEB" ]; then
			echo "Error: Could not find raspbian-archive-keyring package"
			exit 1
		fi
		
		echo "Found latest package: $LATEST_DEB"
		wget -q "$RASPBIAN_POOL_URL/$LATEST_DEB" -O /tmp/raspbian-keyring.deb || {
			echo "Error: Failed to download raspbian-archive-keyring package"
			exit 1
		}
		
		# Extract the keyring
		cd /tmp
		ar x raspbian-keyring.deb
		
		if [ -f data.tar.gz ]; then
			tar -xzf data.tar.gz ./usr/share/keyrings/raspbian-archive-keyring.gpg
		elif [ -f data.tar.xz ]; then
			tar -xJf data.tar.xz ./usr/share/keyrings/raspbian-archive-keyring.gpg
		elif [ -f data.tar.zst ]; then
			tar --zstd -xf data.tar.zst ./usr/share/keyrings/raspbian-archive-keyring.gpg
		else
			echo "Error: Could not find data archive in .deb package"
			exit 1
		fi
		
		# Move to system location
		mv usr/share/keyrings/raspbian-archive-keyring.gpg "${RASPBIAN_KEYRING}"
		chmod 644 "${RASPBIAN_KEYRING}"
		
		# Cleanup
		rm -rf /tmp/raspbian-keyring.deb /tmp/data.tar.* /tmp/usr /tmp/control.tar.* /tmp/debian-binary
		
		echo "✓ Installed raspbian-archive-keyring.gpg with SHA256 signatures"
	fi

	echo "Bootstrapping Raspberry Pi OS base system..."

	# Correct debootstrap invocation:
	# options... <suite> <target> <mirror> (no extra 'bootstrap' token)
	# use --keyring and set --arch=armhf for Raspbian/armhf
	debootstrap --verbose --no-check-gpg --keyring="${RASPBIAN_KEYRING}" --arch=armhf "${RELEASE}" "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/
fi
