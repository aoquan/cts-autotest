#!/bin/bash -x
##################### 
#      安装android_x86
#android_x86_iso_install.sh
#####################
cd ~/android_auto
mkdir ./android_mnt
umount ./android_mnt
#mount ./{android_x86.iso}  ./android_mnt
mount ../android_x86.iso  ./android_mnt

cp  ./android_mnt/kernel         .
cp  ./android_mnt/initrd.img     .
cp  ./android_mnt/ramdisk.img    .
cp  ./android_mnt/system.img     .
umount ./android_mnt
#mkfs.ext4 /dev/{sda3}
mkfs.ext4 /dev/sda2
./fastboot.sh  flashall
