#
# Debootstrap basic system
#

# Load utility functions
. ./functions.sh

if [ "$CHROOT_SOURCE" = "" ] ; then
  # Base debootstrap (unpack only)
  if [ "$ENABLE_MINBASE" = true ] ; then
    http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" --foreign --variant=minbase --include="${APT_INCLUDES}" "${RELEASE}" "${R}" "http://${APT_SERVER}/debian"
  else
    http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" --foreign --include="${APT_INCLUDES}" "${RELEASE}" "${R}" "http://${APT_SERVER}/debian"
  fi

  # Copy qemu emulator binary to chroot
  install_exec "${QEMU_BINARY}" "${R}${QEMU_BINARY}"

  # Copy debian-archive-keyring.pgp
  mkdir -p "${R}/usr/share/keyrings"
  install_readonly /usr/share/keyrings/debian-archive-keyring.gpg "${R}/usr/share/keyrings/debian-archive-keyring.gpg"

  # Complete the bootstrapping process
  chroot_exec /debootstrap/debootstrap --second-stage
else
  sudo cp -r "$CHROOT_SOURCE"/* "${R}"/
fi

# Mount required filesystems
mount -t proc none "${R}/proc"
mount -t sysfs none "${R}/sys"
mount --bind /dev/pts "${R}/dev/pts"
