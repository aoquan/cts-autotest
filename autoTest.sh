#!/bin/bash -x
# install related tools and download related packages

# run qemu
#./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso 

#jdk7_home=/usr/lib/jvm/java-7-openjdk-and64/jre/bin/java
#jdk8_home=/usr/lib/jvm/java-8-oracle/jre/bin/java 
## change the java version command
## update-alternatives --config java

##########################################################################################################################
## $1 : listen port(start from 52001)
## $2 : virtual mechine or real mechine (v/r)
## $3 : ip of client linux system, if you test local android_x86, use localhost or 127.0.0.1
## $4: path of disk(/dev/sda40) or virtual disk(../rawiso/android_x86.raw)
## $5 : run android_x86(run) or install android_x86.iso(install), install and run the testcase(installTest)
## if $5 == install || $5 == installTest
    ## $6: location of android_x86.iso
## if $5 == run
    ## $6: type of test(lkp/cts/all)
        ## if $6 == cts || $6 == all
            ## $7: cts command that need to be excuted
        ## if $6 == lkp
            ## It's enough

## eg: ./autoTest.sh 52001 r 192.168.2.16 /dev/sda40 install android_x86.iso
## eg: ./autoTest.sh 52001 r 192.168.2.16 /dev/sda40 installTest android_x86.iso "-p android.acceleration --disable-reboot"
## eg: ./autoTest.sh 52001 r 192.168.2.16 /dev/sda40 run cts "-p android.acceleration --disable-reboot"
## eg: ./autoTest.sh 52001 r 192.168.2.16 /dev/sda40 run all "-p android.acceleration --disable-reboot"
## eg: ./autoTest.sh 52001 r 192.168.2.16 /dev/sda40 run lkp 
## eg: ./autoTest.sh 52001 v localhost /media/aquan/000D204000041550/android-x86.raw  installTest ../xyl_android_x86_64_5.1.iso "-p android.acceleration --disable-reboot" 

cd "$(dirname "$0")"


# listening port, user should specify it when parallel tesing 
ListenPort=$1
# ListenPort=52001
NATPort=$(($ListenPort+100))

r_v=$2
ip_linux_client=$3
disk_path=$4
run_install=$5 

ip_linux_host=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

ip_android="0.0.0.0"
iso_loc="default"
#check whether the ip address
function checkIP()
{
    count=0
    ip=$1 
    echo $ip
    while [[ $count -ge 0 ]]
    do 
        ping -c 1 $ip &>/dev/null
        if [ $? -eq 0 ];then
            echo -e "\033[32mip is up!\033[0m"
            if [ $count -gt 0 ];then
                sleep 10 
            fi
            break
        else
            sleep 5
            echo -e "\033[31mip is down!\033[0m"
        fi
        count=$(($count+1))
    done
}

checkIP $ip_linux_client


function EditBoot()
{
    if [ ! -d "android_disk" ]; then
        mkdir  android_disk
    fi
    mount -o loop,offset=32256 $disk_path android_disk;
    ########################################
    ## modify init.sh
    line2bottom=`tail android_disk/android*/system/etc/init.sh -n 1`
    sed '$d' -i ./android_disk/android*/system/etc/init.sh

    #echo \$ip | nc -q 0 $ip_linux_host $ListenPort
    if [ "$line2bottom" == "return 0" ]; then
    echo "ip=\`getprop | grep ipaddress\`
    ip=\${ip##*\[}
    ip=\${ip%]*}
    nc -w 2 $ip_linux_host $ListenPort << EOF
        \$ip
EOF
        return 0" >> ./android_disk/android*/system/etc/init.sh
    else
        sed '$d' -i ./android_disk/android*/system/etc/init.sh
        sed '$d' -i ./android_disk/android*/system/etc/init.sh
        sed '$d' -i ./android_disk/android*/system/etc/init.sh
        echo "nc -w 2 $ip_linux_host $ListenPort << EOF
        \$ip
EOF
        return 0" >> ./android_disk/android*/system/etc/init.sh
    fi
    umount android_disk;
}

function getCommitId()
{
    iso_loc=$1
    iso=${iso_loc##*/}
    tmp=${iso#*-}
    commitId=${tmp%-*}
    echo $commitId
}

## according to where it's virtual mechine(qemu) or real mechine, we should change the network model
if [ "$r_v" == "v" ]; then
    ip_android="localhost"

    if [ "$run_install" == "installTest" ] || [ "$run_install" == "install" ];then
        ## install iso and then test the android-x86
        iso_loc=$6
        ./fastboot_vir.sh $disk_path flashall $iso_loc;
        EditBoot

        ## install CtsDeviceAdmin.apk and active the device adminstrators, this setting will take effect after reboot 
        qemu-system-x86_64 -m 2G -vga vmware --enable-kvm -net nic -net user,hostfwd=tcp::$NATPort-:5555 $disk_path -vnc :1 &
        {
            ip_android_v=`nc -lp $ListenPort`
            ## waiting for a message from android-x86, this ip address is useful in real mechine test, but in virtural mechine ,we adopt nat address mapping ,
            ## so it's just a symbol that android-x86 is running 
            echo 'waiting for android boot !!!!!'
            adb connect $ip_linux_client:$NATPort
            sleep 2
            adb -s $ip_linux_client:$NATPort shell system/checkAndroidDesktop.sh
            sleep 5
            ##keep screen active
            adb -s $ip_linux_client:$NATPort shell svc power stayon true
            ## install CtsDeviceAdmin.apk
            echo 'install CtsDeviceAdmin.apk!!!!!'
            adb -s $ip_linux_client:$NATPort install ../android-cts/repository/testcases/CtsDeviceAdmin.apk
            adb -s $ip_linux_client:$NATPort push device_policies.xml data/system/device_policies.xml
            adb -s $ip_linux_client:$NATPORT push commitId.txt data/
            adb -s $ip_linux_client:$NATPort shell poweroff
        }
    fi

    if [ "$run_install" == "installTest" ];then

        #EditBoot
        qemu-system-x86_64 -m 2G -vga vmware --enable-kvm -net nic -net user,hostfwd=tcp::$NATPort-:5555 $disk_path -vnc :2 &
        {
            ip_android_v=`nc -lp $ListenPort`
            echo 'waiting for android boot !!!!!'  

            ## gui haven't been loaded completely for android_x86-5.1 
            adb connect localhost:$NATPort
            sleep 2
            adb -s localhost:$NATPort shell system/checkAndroidDesktop.sh
            sleep 5
            cts_cmd="$7"       

            ### monitor script, if network is down, reboot to linux
            ./testAliveSend.sh localhost $NATPort $r_v &

            ./allinone.sh localhost:$NATPort $iso_loc
            echo "exit" | ../android-cts/tools/cts-tradefed run cts $cts_cmd 
            adb -s localhost:$NATPort shell poweroff
        }
    fi

    if [ "$run_install" == "run" ];then

        EditBoot
        qemu-system-x86_64 -m 2G -vga vmware --enable-kvm -net nic -net user,hostfwd=tcp::$NATPort-:5555 $disk_path -vnc :3 &
        {
            ip_android_v=`nc -lp $ListenPort`
            echo 'waiting for android boot !!!!!'  

            adb connect localhost:$NATPort
            sleep 2
            adb -s localhost:$NATPort shell system/checkAndroidDesktop.sh
	    tmp=`adb -s localhost:NATPort shell cat data/commitId.txt | grep commitId`
	    commitId=${tmp##*:}
            commitId=${commitId%?}
            sleep 5
        
            ### monitor script, if network is down, reboot to linux
            ./testAliveSend.sh localhost $NATPort $r_v &

            testType=$6 
            if [ "$testType" == "cts" ];then
                cts_cmd="$7"
                echo "exit" | ../android-cts/tools/cts-tradefed run cts $cts_cmd 
            elif [ "$testType" == "lkp" ];then
                ./allinone.sh localhost:$NATPort
            elif [ "$testType" == "all" ];then
                cts_cmd="$7"
                ./allinone.sh localhost:$NATPort
                echo "exit" | ../android-cts/tools/cts-tradefed run cts $cts_cmd 
            fi
            adb -s localhost:$NATPort shell poweroff
        }
    fi
    
elif [ "$r_v" == "r" ];then
    if [ "$run_install" == "run" ];then
        ## real mechine
        rsync   -avz -e ssh ./scriptReboot1 root@${ip_linux_client}:~/;
        ssh root@${ip_linux_client} "~/scriptReboot1/reboot.sh $disk_path $ip_linux_host $ListenPort";

        ip_android=`nc -lp $ListenPort`
        echo $ip_android
        adb connect $ip_android
        wait
        echo 'waiting for android boot !!!!!' 
        adb -s $ip_android:5555 shell system/checkAndroidDesktop.sh

        ### get commit id
	tmp=`adb -s $ip_android:5555 shell cat data/commitId.txt | grep commitId`
	commitId=${tmp##*:}
        commitId=${commitId%?}

        echo 'testing'
        ### monitor script, if network is down, reboot to linux
        ./testAliveSend.sh $ip_android 5555 $r_v &

        testType=$6
        if [ "$testType" == "cts" ];then
            cts_cmd="$7"
            echo "exit" | ../android-cts/tools/cts-tradefed run cts $cts_cmd
        elif [ "$testType" == "lkp" ];then
            ./allinone.sh $ip_android:5555
        elif [ "$testType" == "all" ];then
            cts_cmd="$7"
            ./allinone.sh $ip_android:5555
            echo "exit" | ../android-cts/tools/cts-tradefed run cts $cts_cmd
        fi

        ./android_fastboot.sh  $ip_android  reboot_bootloader
    
    elif [ "$run_install" == "installTest" ];then
        ## install android-x86 and then test
        iso_loc=$6
        ./auto2.sh $ip_linux_client $iso_loc $disk_path $ListenPort;
        ip_android=`nc -lp $ListenPort`
        echo "android boot success!"
        #sleep 30
        echo ${ip_android}
        adb connect ${ip_android}
        wait
        adb -s $ip_android:5555 shell system/checkAndroidDesktop.sh

        ##keep screen active
        adb -s $ip_android:5555 shell svc power stayon true
        echo 'install CtsDeviceAdmin.apk!!!!!'
        adb -s $ip_android:5555 install ../android-cts/repository/testcases/CtsDeviceAdmin.apk
        adb -s $ip_android:5555 push device_policies.xml data/system/device_policies.xml
	adb -s $ip_android:5555 push commitId.txt data/
        ./android_fastboot.sh  ${ip_android} bios_reboot 

        ##second boot 
        ip_android=`nc -lp $ListenPort`
        echo "android boot success!"

        #sleep 30
        echo ${ip_android}
        adb connect ${ip_android}
        wait
        adb -s $ip_android:5555 shell system/checkAndroidDesktop.sh
        #sleep 5
        cts_cmd="$7"
        echo 'testing'
        ### monitor script, if network is down, reboot to linux
        ./testAliveSend.sh $ip_android 5555 $r_v &

        ./allinone.sh $ip_android:5555 $iso_loc
        echo "exit" | ../android-cts/tools/cts-tradefed run cts -s $ip_android:5555 $cts_cmd
        ###reboot to  linux
        ./android_fastboot.sh  ${ip_android}  reboot_bootloader

    elif [ "$run_install" == "install" ];then
        ## install android-x86 and then test
        iso_loc=$6
        ./auto2.sh $ip_linux_client $iso_loc $disk_path $ListenPort;
        ip_android=`nc -lp $ListenPort`
        echo "android boot success!"
        #sleep 30
        echo ${ip_android}
        adb connect ${ip_android}
        wait
        adb -s $ip_android:5555 shell system/checkAndroidDesktop.sh

        ##keep screen active
        adb -s $ip_android:5555 shell svc power stayon true
        echo 'install CtsDeviceAdmin.apk!!!!!'
        adb -s $ip_android:5555 install ../android-cts/repository/testcases/CtsDeviceAdmin.apk
        adb -s $ip_android:5555 push device_policies.xml data/system/device_policies.xml
	adb -s $ip_android:5555 push commitId.txt data/
        sleep 1 
        echo "install finished!"
        ###reboot to  linux
        ./android_fastboot.sh  ${ip_android}  reboot_bootloader
    fi
fi

tmp=`find "testlog"$ListenPort".txt" | xargs grep -a "Created result dir"`
#tmp=`grep -a "Created result dir" "testlog"$ListenPort".txt"`
resultDirName=${tmp##* }

if [ "$iso_loc" != "default" ];then
    commitId=`getCommitId $iso_loc`
fi
echo $commitId
### edit result, add commit id
./addCommitId.sh $resultDirName $commitId

ip_android=${ip_android##* }
if [ $resultDirName"x" != "x" ];then
    if [[ ! -d  /mnt/freenas/result/cts/default/$ip_android/android/android_x86/gcc/$commitId ]];then
	mkdir -p /mnt/freenas/result/cts/default/$ip_android/android/android_x86/gcc/$commitId
    fi
    cp -r ../android-cts/repository/results/$resultDirName /mnt/freenas/result/cts/default/$ip_android/android/android_x86/gcc/$commitId
fi
wait
exit
