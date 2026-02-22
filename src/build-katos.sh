#!/bin/bash
set -euo pipefail

# config for KatOS
DISTRO="noble" # please use LTS unless you're build KatOS bleeding edge!
ARCH="amd64" # amd64 is our only supported target at the moment. we may support ARM in the future
IMAGE_DIR="$PWD/katos-build"
ISO_OUTPUT="$PWD/katos.iso"
HOSTNAME="katos"
USERNAME="katos"

# prepare directories
rm -rf "$IMAGE_DIR"
mkdir -p "$IMAGE_DIR"

# bootstrap minimal ubuntu
sudo debootstrap --arch=$ARCH $DISTRO "$IMAGE_DIR" https://archive.ubuntu.com/ubuntu/

# mount special filesystems for chroot
sudo mount --bind /dev "$IMAGE_DIR/dev"
sudo mount --bind /dev/pts "$IMAGE_DIR/dev/pts"
sudo mount -t proc /proc "$IMAGE_DIR/proc"
sudo mount -t sysfs /sys "$IMAGE_DIR/sys"

# chroot into the new system and configure
sudo chroot "$IMAGE_DIR" /bin/bash -c "
set -e
echo '$HOSTNAME' > /etc/hostname
apt-get update
apt-get install -y linux-image-generic grub-pc sudo vim bash-completion
useradd -m -s /bin/bash $USERNAME
echo '$USERNAME:password' | chpasswd
adduser $USERNAME sudo
echo 'LANG=C.UTF-8' > /etc/default/locale
"

# cleanup mounts
sudo umount -lf "$IMAGE_DIR/dev/pts"
sudo umount -lf "$IMAGE_DIR/dev"
sudo umount -lf "$IMAGE_DIR/proc"
sudo umount -lf "$IMAGE_DIR/sys"

# create ISO
sudo grub-mkrescue -o "$ISO_OUTPUT" "$IMAGE_DIR"

# done!
echo "KatOS ISO built at $ISO_OUTPUT"