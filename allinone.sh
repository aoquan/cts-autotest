#! /bin/sh -x
result=/mnt/freenas/result
host=kvm
rootfs=android
kconfig=android_x86
cc=gcc
kernel=6.0

ip=$1
no=$2
mkdir -p $result/ebizzy/default/$host/$rootfs/$kconfig/$cc/$kernel/$no
mkdir -p $result/nbench/default/$host/$rootfs/$kconfig/$cc/$kernel/$no
mkdir -p $result/browser/default/$host/$rootfs/$kconfig/$cc/$kernel/$no

adb -s $ip push ./lkpgui /data/local/tmp
adb -s $ip shell /data/local/tmp/ebizzy > $result/ebizzy/default/$host/$rootfs/$kconfig/$cc/$kernel/$no/ebizzy.out
adb -s $ip shell /data/local/tmp/nbench > $result/nbench/default/$host/$rootfs/$kconfig/$cc/$kernel/$no/nbench.out
adb -s $ip shell uiautomator runtest demo1.jar -c com.browser.demobrowser > $result/browser/default/$host/$rootfs/$kconfig/$cc/$kernel/$no/browser.out
