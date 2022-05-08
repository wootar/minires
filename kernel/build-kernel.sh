wget -O kernel.tar.gz https://git.kernel.org/torvalds/t/linux-5.18-rc5.tar.gz
mkdir modules
tar xvf kernel.tar.gz
mv linux-* src
cd src
mkdir out
cp ../kconfig out/.config
yes " " | make oldconfig O=out
make -j4 O=out
make modules_install O=out INSTALL_MOD_PATH=../../modules
cp out/arch/x86/boot/bzImage ../bzImage
