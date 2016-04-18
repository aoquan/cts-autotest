#!/bin/bash
# install related tools and download related packages

# run qemu
#./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso 

#jdk7_home=/usr/lib/jvm/java-7-openjdk-and64/jre/bin/java
#jdk8_home=/usr/lib/jvm/java-8-oracle/jre/bin/java 
## change the java version command
## update-alternatives --config java

## $1 : virtual mechine or real mechine (v/r)
## $2 : run android_x86.iso or raw in qemu (iso/raw)
## $3 : ip_linux_client

## example:
## virtual mechine: sudo ./autoTest.sh v raw
## real mechine: sudo ./autoTest.sh r 192.168.2.16 


ip_linux_host=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

## according to where it's virtual mechine(qemu) or real mechine, we should change the network model
if [ "$1" == "v" ]; then
	if [ "$2" == "iso" ]; then
		#/home/aquan/work/qemu-2.5.0/x86_64-softmmu/qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no android_x86.iso 
		##qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no android_x86.iso 
		## install iso in to raw
		mkdir android_raw;
		mkdir android_mnt;
		mkdir system_tmp;
		mount -o loop,offset=32256 ~/git/cts-autotest/rawiso/android_x86.raw android_raw;
		mount ~/git/cts-autotest/rawiso/android_x86_64_4.4.iso  android_mnt;
		mount android_mnt/system.img system_tmp;

		rm android_raw/android-2016-02-29/* -r;
		mkdir android_raw/android-2016-02-29/system;
		cp   -Ra ./system_tmp/*   ./android_raw/android-2016-02-29/system;
		cp  ./android_mnt/kernel         android_raw/;
		cp  ./android_mnt/initrd.img     android_raw/;
		cp  ./android_mnt/ramdisk.img    android_raw/;
		cp  ./android_mnt/system.img     android_raw/;

		umount system_tmp;
		umount android_mnt;
		umount android_raw;

		rm -r system_tmp;
		rm -r android_mnt;
		rm -r android_raw;

		qemu-system-x86_64 -m 4G --enable-kvm /home/aquan/work/cts/android_x86.raw
	elif [ "$2" == "raw" ];then
		#######################################################
		## replace file specified by user
		./virFastboot.sh $3


		#/home/aquan/work/qemu-2.5.0/x86_64-softmmu/qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no /home/aquan/work/cts/android_x86.raw &
		qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no /home/aquan/work/cts/android_x86.raw &
		{
			ip_android_v=`nc -lp 5556`
			adb connect $ip_android_v
			../android-cts/tools/cts-tradefed run cts --plan CTS --disable-reboot  
			adb disconnect $ip_android_v	
		}
	fi
elif [ "$1" == "r" ];then
	## real mechine
	ip_linux_client=$2
	autoFrame/android_tool.sh $ip_linux_client fastboot.sh $3


	ip_android_r=`nc -lp 5556`
	adb connect $ip_android_r
	../android-cts/tools/cts-tradefed run cts --plan CTS --disable-reboot  
	adb disconnect $ip_android_r

fi





