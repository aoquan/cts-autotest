#!/bin/bash
# install related tools and download related packages

# run qemu
#./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso 

#jdk7_home=/usr/lib/jvm/java-7-openjdk-and64/jre/bin/java
#jdk8_home=/usr/lib/jvm/java-8-oracle/jre/bin/java 
## change the java version command
## update-alternatives --config java

#################################################################
## $1 : virtual mechine or real mechine (v/r)
## $2 : run android_x86.iso or raw in qemu (iso/raw), for automatic installation iso have not been implemented, you can not input raw  
## $3 : if $1=v, $3 stand for location of raw or iso
##      if $1=r, $3 stand for location of android_x86 system (which sda?)
## $4 : cts command

## example:
## virtual mechine: sudo ./autoTest.sh v raw ../rawiso/android_x86.raw "--plan CTS --disable-reboot"
## real mechine: sudo ./autoTest.sh r 192.168.2.16 /dev/sda4 "--plan CTS --disable-reboot"
#################################################################


ip_linux_host=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
ctsCmd="$4"

## according to where it's virtual mechine(qemu) or real mechine, we should change the network model
if [ "$1" == "v" ]; then
	if [ "$2" == "raw" ];then
		rawIsoLocation=$3

		if [ ! -d "android_disk" ]; then
			mkdir  android_disk
		fi
		mount -o loop,offset=32256 $rawIsoLocation android_disk;
		sed '$d' -i ./android_disk/android*/system/etc/init.sh
		sed '$d' -i ./android_disk/android*/system/etc/init.sh
		echo "echo \$ip | nc -q 0 $ip_linux_host 5556
			return
			" >> ./android_disk/android*/system/etc/init.sh
		umount android_disk;

		qemu-system-x86_64 -m 2G --enable-kvm -net nic -net user,hostfwd=tcp::5557-:5555 $rawIsoLocation &
		{
			ip_android_v=`nc -lp 5556`
			## waiting for a message from android-x86, this ip address is useful in real mechine test, but in virtural mechine ,we adopt nat address mapping ,
			## so it's just a symbol that android-x86 is running 
			adb connect localhost:5557
			#../android-cts/tools/cts-tradefed run cts --plan CTS --disable-reboot
			../android-cts/tools/cts-tradefed run cts $ctsCmd
			adb disconnect localhost:5557
		}
	fi
elif [ "$1" == "r" ];then
	## real mechine
	ip_linux_client=$2
	androidLocation=$3
	## loction(sda) of android system 

	ssh root@${ip_linux_client}
	if [ ! -d "android_disk" ]; then
			mkdir  android_disk
	fi
	#mount /dev/sda4 android_disk;
	mount androidLocation android_disk;

	line2bottom=`tail android_disk/android*/system/etc/init.sh -n 2 |head -n 1`

	sed '$d' -i ./android_disk/android*/system/etc/init.sh
	sed '$d' -i ./android_disk/android*/system/etc/init.sh

	if [ "$line2bottom" == "" ]; then
		echo "ip=\`getprop | grep ipaddress\`
		ip=\${ip##*\[}
		ip=\${ip%]*}
		echo \$ip | nc -q 0 $ip_linux_host 5556
		return 0" >> ./android_disk/android*/system/etc/init.sh
	else
		echo "		echo \$ip | nc -q 0 $ip_linux_host 5556
		return 0" >> ./android_disk/android*/system/etc/init.sh
	fi
	umount android_disk;
	efibootmgr -n 6
	reboot

	## return to linux_host command
	ip_android_r=`nc -lp 5556`
	adb connect $ip_android_r
	../android-cts/tools/cts-tradefed run cts --plan CTS --disable-reboot  
	adb disconnect $ip_android_r
fi





