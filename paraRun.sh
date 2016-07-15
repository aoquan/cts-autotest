#!/bin/bash -x
cd "$(dirname "$0")" 
port=52000
iso=$1
while read line
do 
    if [[ $line"x" == "x" ]];then 
        break
    fi
	let port+=1
	cmd="./autoTest.sh "
	#cmd=$cmd"$line"" $port"
	eval "$cmd $port $line" > testlog$port".txt" &
	echo "done!"
done < configs

wait
pkill adb
pkill nc
exit



# ./autoTest.sh v install localhost ../android-x86.raw "-p android.acceleration --disable-reboot" ../xyl_android_x86_64_6.0.iso
# ./autoTest.sh r install 192.168.2.82 /dev/sda40 "-p android.acceleration --disable-reboot" ../xyl_android_x86_64_6.0.iso
# ./autoTest.sh r install 192.168.2.80 /dev/sda40 "-p android.acceleration --disable-reboot" ../xyl_android_x86_64_6.0.iso
# ./autoTest.sh r install 192.168.2.17 /dev/sda40 "-p android.acceleration --disable-reboot" ../xyl_android_x86_64_6.0.iso
#v install localhost /media/aquan/000D204000041550/android-x86.raw "-p android.acceleration --disable-reboot" ../xyl_android_x86_64_6.0.iso
#v install localhost /media/aquan/000D204000041550/research/android-x86-6.0.raw "-p android.acceleration --disable-reboot" /home/aquan/git/xyl_android_x86_64_6.0.iso
#v install localhost /media/aquan/000D204000041550/android-x86.raw "-p android.acceleration --disable-reboot" /home/aquan/git/xyl_android_x86_64_6.0.iso
#v install localhost /media/aquan/000D204000041550/research/android-x86-6.0.raw "-p android.acceleration --disable-reboot" /home/aquan/git/xyl_android_x86_64_6.0.iso
