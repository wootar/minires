#!/bin/sh
echo "Building MiniRES Image"
wget -O rootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/alpine-minirootfs-20220328-x86_64.tar.gz || exit 1

mkdir rootfs
cd rootfs
tar xvf ../rootfs.tar.gz
cd ..

echo "Configuring rootfs"
echo "nameserver 1.1.1.1" > rootfs/etc/resolv.conf
echo "nameserver 1.0.0.1" > rootfs/etc/resolv.conf
echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> rootfs/etc/apk/repositories

echo "echo 'Bootstrapping MiniRES on $(date '+%d-%M-%Y (DD-MM-YYYY)')'
apk update
apk upgrade
apk add busybox busybox-extras htop cfdisk parted util-linux nano shellcheck links dhcpcd gpm iwd kexec-tools neofetch pfetch lynx openssh-server || exit 1
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
" > rootfs/bootstrap.sh
cd rootfs
echo "Now for the main part, generating the image!"
chroot . /bin/sh /bootstrap.sh || exit 1
cd ..

cp -rv skeleton/* rootfs/
DATE=$(date +%y.%m.%d)
SED="s/REPLACEME/${DATE}/g'"
cat skeleton/etc/os-release | sed "s/REPLACEME/${DATE}/g" > rootfs/etc/os-release
rm rootfs/bootstrap.sh
cd rootfs
cp -rv ../kernel/modules/lib/* lib
cp -rv ../kernel/modules/lib/* lib
find . -print0 | cpio --null --verbose \
 --create --format=newc | gzip \
 --best > ../out.cpio.gz; cd .. || exit 1
