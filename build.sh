#!/bin/bash

# Modified from https://github.com/palera1n/palen1x

[ "$(id -u)" -ne 0 ] && {
    echo 'Please run as root'
    exit 1
}
ROOTFS='https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-minirootfs-3.17.3-x86_64.tar.gz'
cat << EOF

 █    ██  ███▄    █   ██████  ██░ ██  ▄▄▄       ▄████▄   ██ ▄█▀ ██▓    ▓█████ 
 ██  ▓██▒ ██ ▀█   █ ▒██    ▒ ▓██░ ██▒▒████▄    ▒██▀ ▀█   ██▄█▒ ▓██▒    ▓█   ▀ 
▓██  ▒██░▓██  ▀█ ██▒░ ▓██▄   ▒██▀▀██░▒██  ▀█▄  ▒▓█    ▄ ▓███▄░ ▒██░    ▒███   
▓▓█  ░██░▓██▒  ▐▌██▒  ▒   ██▒░▓█ ░██ ░██▄▄▄▄██ ▒▓▓▄ ▄██▒▓██ █▄ ▒██░    ▒▓█  ▄ 
▒▒█████▓ ▒██░   ▓██░▒██████▒▒░▓█▒░██▓ ▓█   ▓██▒▒ ▓███▀ ░▒██▒ █▄░██████▒░▒████▒
░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒ ▒▒   ▓▒█░░ ░▒ ▒  ░▒ ▒▒ ▓▒░ ▒░▓  ░░░ ▒░ ░
░░▒░ ░ ░ ░ ░░   ░ ▒░░ ░▒  ░ ░ ▒ ░▒░ ░  ▒   ▒▒ ░  ░  ▒   ░ ░▒ ▒░░ ░ ▒  ░ ░ ░  ░
 ░░░ ░ ░    ░   ░ ░ ░  ░  ░   ░  ░░ ░  ░   ▒   ░        ░ ░░ ░   ░ ░      ░   
   ░              ░       ░   ░  ░  ░      ░  ░░ ░      ░  ░       ░  ░   ░  ░
                                               ░                              
open source tool to bypass windows and linux passwords
github : https://github.com/Fadi002/unshackle
EOF
apt-get update
apt-get install -y --no-install-recommends wget gawk debootstrap mtools xorriso ca-certificates curl libusb-1.0-0-dev gcc make gzip xz-utils unzip libc6-dev
VERSION=$(<version)

# Clean up previous attempts
umount -v work/rootfs/{dev,sys,proc} >/dev/null 2>&1
rm -rf work
mkdir -pv work/{rootfs,iso/boot/grub}
cd work

# Fetch ROOTFS
curl -sL "$ROOTFS" | tar -xzC rootfs
mount -vo bind /dev rootfs/dev
mount -vt sysfs sysfs rootfs/sys
mount -vt proc proc rootfs/proc
cp /etc/resolv.conf rootfs/etc
cat << ! > rootfs/etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/v3.12/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
!

sleep 2
# ROOTFS packages & services
cat << ! | chroot rootfs /usr/bin/env PATH=/usr/bin:/usr/local/bin:/bin:/usr/sbin:/sbin /bin/sh
apk update
apk upgrade
apk add bash alpine-base ncurses udev newt lsblk linux-headers usbutils xkeyboard-config
apk add linux-headers
apk add xkeyboard-config
apk add ntfs-3g
apk add e2fsprogs
apk add coreutils
apk add usbutils
apk add --no-scripts linux-lts linux-firmware-none
modprobe hid-generic
rc-update add bootmisc
rc-update add hwdrivers
rc-update add udev
rc-update add udev-trigger
rc-update add udev-settle
!

# kernel modules
cat << ! > rootfs/etc/mkinitfs/features.d/unshackle.modules
kernel/net/ipv4
modprobe hid-generic
!
chroot rootfs /usr/bin/env PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin \
	/sbin/mkinitfs -F "unshackle" -k -t /tmp -q $(ls rootfs/lib/modules)
# rm -rfv rootfs/lib/modules
mv -v rootfs/tmp/lib/modules rootfs/lib
find rootfs/lib/modules/* -type f -name "*.ko" -exec strip -v --strip-unneeded {} \; -exec xz --x86 -v9eT0 \;
depmod -b rootfs $(ls rootfs/lib/modules)

# Echo TUI configurations
echo 'unshackle' > rootfs/etc/hostname
echo "PATH=$PATH:$HOME/.local/bin" > rootfs/root/.bashrc # d
echo "export unshackle_VERSION='$VERSION'" > rootfs/root/.bashrc
echo "chmod -v 755 /usr/bin/*" > rootfs/root/.bashrc
echo '/usr/bin/unshackle_menu' >> rootfs/root/.bashrc
echo "" > rootfs/usr/bin/.args

# Unmount fs
umount -v rootfs/{dev,sys,proc}

# Copy files
cp "../unshackle" rootfs/usr/bin/unshackle
cp "../sethc.exe" rootfs/usr/sbin/sethc.exe
chmod +x rootfs/usr/bin/unshackle
cp -av ../inittab rootfs/etc
cp -v ../scripts/* rootfs/usr/bin
chmod -v 755 rootfs/usr/local/bin/*
chroot rootfs /usr/bin/env PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin \
	chmod -v 755 /usr/local/bin/*
ln -sv sbin/init rootfs/init
ln -sv ../../etc/terminfo rootfs/usr/share/terminfo # fix ncurses

# Boot config
cp -av rootfs/boot/vmlinuz-lts iso/boot/vmlinuz
cat << ! > iso/boot/grub/grub.cfg
insmod all_video
echo 'unshackle $VERSION'
linux /boot/vmlinuz quiet loglevel=3
initrd /boot/initramfs.xz
boot
!

# initramfs
pushd rootfs
rm -rfv tmp/* boot/* var/cache/* etc/resolv.conf
find . | cpio -oH newc | xz -C crc32 --x86 -vz9eT$(nproc --all) > ../iso/boot/initramfs.xz
popd

# ISO creation
grub-mkrescue -o "unshackle-$VERSION.iso" iso --compress=xz

