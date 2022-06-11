wget -O - https://git.kernel.org/torvalds/t/linux-5.19-rc1.tar.gz | gunzip | tar x || exit 1
mkdir modules
mv linux-* src
cd src
mkdir out
cp ../kconfig out/.config
make olddefconfig O=out 
make -j$(nproc) O=out || exit 1
make modules_install O=out INSTALL_MOD_PATH=../../modules
cp out/arch/x86/boot/bzImage ../bzImage
