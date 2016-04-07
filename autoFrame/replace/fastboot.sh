#!/bin/bash
ip_linux_host=192.168.2.36
cd autoFrame/replace

if [ ! -d "./android_disk" ]; then
	mkdir ./android_disk
fi

#umount ./android_disk
mount /dev/sda2   ./android_disk

if [ ! -d "./android_disk/android-2016-02-29/" ]; then
	mkdir  ./android_disk/android-2016-02-29/
fi

if [ ! -d "./android_disk/android-2016-02-29/system" ]; then
	mkdir -p ./android_disk/android-2016-02-29/system
fi

if [ ! -d "./android_disk/android-2016-02-29/data" ]; then
	mkdir -p ./android_disk/android-2016-02-29/data
fi

## change the /system/etc/init.sh
## we need add statements to get the ip address of android_x86 and send it to linux
##

## firstly, we check whether the second line from the bottom of init.sh is null(1) or "echo $ip | nc -q 0 $ip_linux_host 5556"(2)
## condition (1) : we add  "echo $ip | nc -q 0 $ip_linux_host 5556"
## else : replace this line with new statement
line2bottom=`tail android_disk/android-2016-02-29/system/etc/init.sh -n 2 |head -n 1`
if [ "$line2bottom" == "" ]; then
	sed '$d' -i ./android_disk/android-2016-02-29/system/etc/init.sh
	echo "ip=\`getprop | grep ipaddress\`
	ip=\${ip##*\[}
	ip=\${ip%]*}
	echo \$ip | nc -q 0 $ip_linux_host 5556
	return 0" >> ./android_disk/android-2016-02-29/system/etc/init.sh
fi
#######################################################

if [ "$1" = "flashall" ]; then
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


if [ "$1" = "replace-kernel" ]; then
	cp  ./kernel        ./android_disk/android-2016-02-29/kernel
	efibootmgr -n 6
	reboot
fi

if [ "$1" = "replace-initrd" ]; then
	cp  ./initrd.img    ./android_disk/android-2016-02-29/initrd.img
	efibootmgr -n 6
	reboot
fi

if [ "$1" = "repalce-ramdisk" ]; then
	cp  ./ramdisk.img   ./android_disk/android-2016-02-29/ramdisk.img
	efibootmgr -n 6
	reboot
fi

if [ "$1" = "replace-system" ]; then
	if [ ! -d "./android_disk" ]; then
		mkdir   ./system_tmp
	fi
	umount ./system_tmp
	mount ./system.img ./system_tmp
	rm -rf ./android_disk/android-2016-02-29/system/*
	cp -Ra ./system_tmp/*   ./android_disk/android-2016-02-29/system
	umount ./system_tmp
	efibootmgr -n 6
	reboot
fi

if [ "$1" == "reboot" ]; then
	efibootmgr -n 6
	reboot
fi

if [ "$1" = "reboot-bootloader" ]; then
	reboot
fi


## install android_x86_iso
if [ "$1" = "install_iso" ]
	then
	cd ~/autoFrame
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