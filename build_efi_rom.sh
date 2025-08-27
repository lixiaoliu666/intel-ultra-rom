#!/bin/bash
git clone https://github.com/tianocore/edk2.git
git submodule update --init
cp -r Build edk2/
cd edk2
git submodule update --init
source edksetup.sh
git clone https://github.com/tomitamoeko/VfioIgdPkg.git
cd VfioIgdPkg
bash add-to-ovmfpkg.sh
cd ..
git diff > edk2-autoGenPatch.patch
sed -i 's:^ACTIVE_PLATFORM\s*=\s*\w*/\w*\.dsc*:ACTIVE_PLATFORM       = OvmfPkg/OvmfPkgX64.dsc:g' Conf/target.txt
sed -i 's:^TARGET_ARCH\s*=\s*\w*:TARGET_ARCH           = X64:g' Conf/target.txt
sed -i 's:^TOOL_CHAIN_TAG\s*=\s*\w*:TOOL_CHAIN_TAG        = GCC5:g' Conf/target.txt
make -C BaseTools
build -DFD_SIZE_4MB -DDEBUG_ON_SERIAL_PORT=TRUE
cp Build/OvmfX64/DEBUG_GCC5/X64/PlatformGopPolicy.efi Build/
cp Build/OvmfX64/DEBUG_GCC5/X64/IgdAssignmentDxe.efi Build/
cp ./BaseTools/Source/C/bin/EfiRom Build/
cd Build
./EfiRom -e pc-ultra-1-2-IntelGopDriver.efi IgdAssignmentDxe.efi PlatformGopPolicy.efi -f 0x8086 -i 0xffff -o ultra-1-2-qemu10.rom
ls
