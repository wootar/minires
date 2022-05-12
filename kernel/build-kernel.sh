wget -O kernel.tar.gz https://git.kernel.org/torvalds/t/linux-5.18-rc6.tar.gz
mkdir modules
tar xvf kernel.tar.gz
mv linux-* src
cd src
mkdir out
cp ../kconfig out/.config
yes " " | make oldconfig O=out 
make -j$(nproc) O=out || exit 1
make modules_install O=out INSTALL_MOD_PATH=../../modules
cp out/arch/x86/boot/bzImage ../bzImage
