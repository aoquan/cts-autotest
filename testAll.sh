#!/bin/bash 
./autoTest.sh r install 192.168.2.51 /dev/sda40 "-p android.acceleration --disable-reboot" ../android_x86_64-5.1.iso
./autoTest.sh r start 192.168.2.51 /dev/sda40 
