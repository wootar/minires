
echo "MiniRes Build Image"
wget -O rootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/alpine-minirootfs-20220328-x86_64.tar.gz

mkdir rootfs
cd rootfs
tar xvf ../rootfs.tar.gz
cd ..

echo "nameserver 1.1.1.1" > rootfs/etc/resolv.conf
echo "nameserver 1.0.0.1" > rootfs/etc/resolv.conf
echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> rootfs/etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> rootfs/etc/apk/repositories

echo "apk update
apk upgrade
apk add busybox busybox-extras htop cfdisk parted util-linux nano shellcheck v86d links dhcpcd gpm iwd kexec-tools neofetch || exit 1
apk del openrc busybox-initscripts || true
ln -s /bin/busybox /sbin/init
ln -s /bin/busybox /init
ln -s /bin/busybox /linuxrc
rm -f /etc/motd
rm -f /etc/issue
echo 'Goodbye apk!'
rm -f /sbin/apk
rm -rf /etc/apk
rm -rf /lib/apk
rm -rf /usr/share/apk
rm -rf /var/lib/apk
rm /bootstrap.sh
" > rootfs/bootstrap.sh
cd rootfs
chroot . /bin/sh /bootstrap.sh
cd ..

cp -rv skeleton/* rootfs/
DATE=$(date +%y.%m.%d)
SED="s/REPLACEME/${DATE}/g'"
cat skeleton/etc/os-release | sed "s/REPLACEME/${DATE}/g" > rootfs/etc/os-release
rm rootfs/bootstrap.sh
cp -rv kernel/src/modules/lib/* rootfs/lib && cd rootfs; find . -print0 | cpio --null --verbose --create --format=newc | gzip --best > ../out.cpio.gz; cd ..
