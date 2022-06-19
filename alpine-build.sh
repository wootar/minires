#!/bin/sh
echo "Building MiniRES Image"
echo "Downloading rootfs"
wget -O rootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/alpine-minirootfs-20220328-x86_64.tar.gz

mkdir rootfs
mkdir rootfs/rootfs
mkdir rootfs/proc
mkdir rootfs/sys
mkdir rootfs/dev
mkdir rootfs/bin
cd rootfs
tar -C rootfs xvf ../rootfs.tar.gz &> /dev/null
cd ..

echo "Configuring rootfs"
echo "nameserver 1.1.1.1" > rootfs/rootfs/etc/resolv.conf
echo "nameserver 1.0.0.1" > rootfs/rootfs/etc/resolv.conf
echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > rootfs/rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> rootfs/rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> rootfs/rootfs/etc/apk/repositories

echo "echo 'Bootstrapping MiniRES on $(date '+%d-%M-%Y (DD-MM-YYYY)')'
apk update
apk upgrade
apk add busybox busybox-static busybox-extras htop cfdisk parted util-linux nano shellcheck links dhcpcd gpm iwd kexec-tools neofetch pfetch lynx openssh-server || exit 1
apk del openrc busybox-initscripts || true
echo 'Fixing links to the init'
ln -s /bin/busybox /sbin/init
ln -s /bin/busybox /init
ln -s /bin/busybox /linuxrc
rm -f /etc/motd
rm -f /etc/issue
echo 'Removing apk (Package Manager)'
rm -f /sbin/apk
rm -rf /etc/apk
rm -rf /lib/apk
rm -rf /usr/share/apk
rm -rf /var/lib/apk
echo 'Removing bootstrap script'
rm /bootstrap.sh
" > rootfs/rootfs/bootstrap.sh
cd rootfs/rootfs
echo "Now for the main part, generating the image!"
chroot . /bin/ash /bootstrap.sh || exit 1
cp bin/busybox.static ../bin/busybox
cd ../..

cp -rv skeleton/* rootfs/
DATE=$(date +%y.%m.%d)
SED="s/REPLACEME/${DATE}/g'"
cat skeleton/etc/os-release | sed "s/REPLACEME/${DATE}/g" > rootfs/etc/os-release
rm rootfs/rootfs/bootstrap.sh
cd rootfs
cp -rv ../kernel/modules/lib/* rootfs/lib
cp -rv ../kernel/modules/lib/* rootfs/lib
echo "Now generating the minires initrd"
find . -print0 | cpio --null --verbose \
 --create --format=newc | gzip \
 --best > ../out.cpio.gz; cd .. || exit 1
echo "Done!"
echo "You may test it by running qemu-system-x86_64 -kernel kernel/bzImage -initrd -m 512M -accel tcg"
