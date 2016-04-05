#!/bin/bash

## cts auto test script, rewritten by aoquan
## reference maoyingming's script
## you can run this script in the cts_auto directory

## there are  paremeters you should specify
## 1. install android_x86 through uefi 
## 2. ip address of test linux 
## 3. install android_x86 or replace part of android_x86 such as change kernel
## 4. ip address of test android

## default ip address of ubuntu and android_x86
##ip_linux_client="192.168.2.16"
##ip_android="192.168.2.34"

## only install one time. 
#./android_tool.sh ${ip_linux_client} android_x86_uefi_install.sh

ip_linux_client=$1
action=$2

if [ "$action" == "uefi" ]
	then
	./android_tool.sh $ip_linux_client android_x86_uefi_install.sh
	exit
fi

if [ "$action" == "install_iso" ]
	then
	./android_tool.sh $ip_linux_client android_x86_iso_install.sh
fi

if [ "$action" != "uefi" ] && [ "$action" != "install_iso" ]
	then	
	./android_tool.sh $ip_linux_client fastboot.sh $action
fi

## waiting for android start
## we add a statement to android's file /system/etc/init.sh
## this would run when android start, android will send it's ip address to linux 
## listen port 5556
ip_android=`nc -lp 5556`
###
##test ip  reacheable
adb connect ${ip_android}
adb install ./net.jishigou.t2.8.0.apk
adb shell am start -n net.jishigou.t/net.jishigou.t.StartActivity
