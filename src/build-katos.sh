#!/bin/bash
set -euo pipefail

# ensure script is running as sudo
if [ "$EUID" -eq 0 ]; then
    echo "Running as sudo! Continuing..."
else
    echo "Please run this script as sudo."
    exit 1
fi

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
sudo mount -t tmpfs tmp "$IMAGE_DIR/tmp"

# chroot into the new system and configure
sudo chroot "$IMAGE_DIR" /bin/bash -c "
set -e
export DEBIAN_FRONTEND=noninteractive

# hostname
echo '$HOSTNAME' > /etc/hostname

# locales
echo 'LANG=C.UTF-8' > /etc/default/locale
apt-get update
apt-get install -y --no-install-recommends linux-image-generic linux-headers-generic grub-pc sudo bash-completion vim systemd-sysv

# user
useradd -m -s /bin/bash $USERNAME
echo '$USERNAME:password' | chpasswd
adduser $USERNAME sudo

# grub config
mkdir -p /boot/grub
cat > /boot/grub/grub.cfg << 'EOF'
set default=0
set timeout=5

menuentry "KatOS" {
    linux /boot/vmlinuz root=/dev/sr0 quiet
    initrd /boot/initrd.img
}
EOF
"

# cleanup mounts
sudo umount -lf "$IMAGE_DIR/dev/pts"
sudo umount -lf "$IMAGE_DIR/dev"
sudo umount -lf "$IMAGE_DIR/proc"
sudo umount -lf "$IMAGE_DIR/sys"
sudo umount -lf "$IMAGE_DIR/tmp"

# create ISO
sudo grub-mkrescue -o "$ISO_OUTPUT" "$IMAGE_DIR"

# done!
echo "KatOS ISO built to $ISO_OUTPUT"