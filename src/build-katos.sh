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
PROFILE_DIR="katos-profile"
OUT_DIR="out"
WORK_DIR="work"

# make sure the directories are empty to avoid conflicts
#
# FIXME: theres probably a less nuclear option to do this so we can use cache
# and not build from zero each time
echo "Getting KatOS ready to build..."
sudo rm -rf "$PROFILE_DIR"
sudo rm -rf "$OUT_DIR"
sudo rm -rf "$WORK_DIR"

# then, recreate the profile dir with arch's releng
echo "Creating profile for KatOS..."
cp -r /usr/share/archiso/configs/releng "$PROFILE_DIR"

# update iso label
echo "Updating ISO label..."
sed -i 's/iso_name="archlinux"/iso_name="katos"/g' \
    "$PROFILE_DIR/profiledef.sh"

sed -i 's/iso_label="ARCH_.*/iso_label="KATOS"/g' \
    "$PROFILE_DIR/profiledef.sh"

# add custom packages to be installed in the live iso
#echo "Getting packages ready for install..."
#cat >> "$PROFILE_DIR/packages.x86_64" << EOF
#
# packages that katos will install
#git
#fastfetch
#networkmanager
#base-devel

# we want the lts linux kernel for stability!
#linux-lts
#EOF

# create directory for custom executables inside the live system
# anything here becomes available at /usr/local/bin on boot
echo "Setting up directory for custom apps..."
mkdir -p "$PROFILE_DIR/airootfs/usr/local/bin"

# copy over our patches to the airootfs
echo "Copying patches to airootfs..."
mkdir -p "$PROFILE_DIR/airootfs" # directory should exist... just in case, check!
cp -r patch/. "$PROFILE_DIR"

# start iso build process
echo "Building ISO..."
sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

# done!
echo ""
echo "Done!"
echo "KatOS was built to $OUT_DIR"