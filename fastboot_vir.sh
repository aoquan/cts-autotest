#!/bin/bash -x
###################### 
## $1 : disk path(/dev/sda40)
## $2 : 
disk_path=$1
boot_cmd=$2

#cd  ~/android_auto


mkdir ./android_disk
umount ./android_disk
mount -o loop,offset=32256 $disk_path  ./android_disk;

echo $disk_path
echo $boot_cmd
sleep 2
if [ "$boot_cmd" = "flashall" ];then

	rm ./android_disk/android-2016-02-29/system/* -r
	rm ./android_disk/android-2016-02-29/data/* -r
	rm ./android_disk/android-2016-02-29/kernel
	rm ./android_disk/android-2016-02-29/initrd.img
	rm ./android_disk/android-2016-02-29/ramdisk.img

	cp  ./kernel        ./android_disk/android-2016-02-29/kernel
	cp  ./initrd.img    ./android_disk/android-2016-02-29/initrd.img
	cp  ./ramdisk.img   ./android_disk/android-2016-02-29/ramdisk.img

	mkdir   ./system_tmp
	sleep 2
	umount ./system_tmp

	if [ -f "./system.sfs" ]; then 
		mkdir  ./sfstmp
		mount -t squashfs ./system.sfs  ./sfstmp
		sleep 3
		cp ./sfstmp/system.img   .
	fi 

	mount ./system.img ./system_tmp
	sleep 3
	rm -rf ./android_disk/android-2016-02-29/system/*
	cp   -Ra ./system_tmp/*   ./android_disk/android-2016-02-29/system
	sleep 3
	umount ./system_tmp
	sleep 3
fi
umount ./android_disk;
