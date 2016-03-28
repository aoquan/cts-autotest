#!/bin/bash
# install related tools and download related packages

# run qemu
#./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso 



if [ $# -eq 0 ];
then 
    adb connect 192.168.2.44:5555
fi
adb connect $1
./cts-tradefed run cts --plan CTS --disable-reboot  
