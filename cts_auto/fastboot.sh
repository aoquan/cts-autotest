#!/bin/bash
mkdir ./android_disk
umount ./android_disk
mount /dev/sda2   ./android_disk

mkdir  ./android_disk/android-2016-02-29/
mkdir -p ./android_disk/android-2016-02-29/system
mkdir -p ./android_disk/android-2016-02-29/data

## change the /system/etc/init.sh
## we need add statements to get the ip address of android_x86 and send it to linux
## 
ip=`getprot | grep ipaddress`
ip=${ip##*\[}
ip=${ip%]*}
sendStr = "echo 'echo todosomething' | nc -q 0 $ip 5556"
sed -i '$i\$sendStr'  ./android_disk/android-2016-02-29/system/etc/init.sh
#######################################################

echo $1
sleep 2
## ??? why sleep 2 ?

if [ "$1" = "flashall" ]
then
cp  ./kernel        ./android_disk/android-2016-02-29/kernel
cp  ./initrd.img    ./android_disk/android-2016-02-29/initrd.img
cp  ./ramdisk.img   ./android_disk/android-2016-02-29/ramdisk.img

mkdir   ./system_tmp
sleep 2
umount ./system_tmp
mount ./system.img ./system_tmp
rm -rf ./android_disk/android-2016-02-29/system/*
cp   -Ra ./system_tmp/*   ./android_disk/android-2016-02-29/system
umount ./system_tmp
fi


if [ "$1" = "kernel" ]
then
cp  ./kernel        ./android_disk/android-2016-02-29/kernel
fi



if [ "$1" = "initrd" ]
then
cp  ./initrd.img    ./android_disk/android-2016-02-29/initrd.img
fi



if [ "$1" = "ramdisk" ]
then
cp  ./ramdisk.img   ./android_disk/android-2016-02-29/ramdisk.img
fi



if [ "$1" = "system" ]
then
mkdir   ./system_tmp
umount ./system_tmp
mount ./system.img ./system_tmp
rm -rf ./android_disk/android-2016-02-29/system/*
cp   -Ra ./system_tmp/*   ./android_disk/android-2016-02-29/system
umount ./system_tmp
fi



if [ "$1" = "reboot" ]
then
#efibootmgr -n {4}
efibootmgr -n 6
reboot
fi



if [ "$1" = "reboot-bootloader" ]
then
reboot
fi


## install android_x86_iso
if ["$1" = "install_iso"]
	then
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
fi