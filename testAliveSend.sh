#!/bin/bash
ip=$1
port=$2
hostType=$3
adb devices | grep "$ip:$port"
if [[ $? -eq 1 ]];then
    #adb connect $ip
    exit
fi
adb -s $ip:$port push alive.txt data/ 
adb -s $ip:$port push testAliveReceive.sh data/
#adb -s $ip:$port shell chmod +x data/testAliveReceive.sh
adb -s $ip:$port shell "busybox nohup data/testAliveReceive.sh alive.txt $hostType" &
#pid=$!
#sleep 2
#pkill $pid
#./runTestAliveReceive.sh $ip $port &

while true
do
    sleep 10
    ping $ip -c 1 > /dev/null 
    if [[ $? -eq 0 ]];then
        adb -s $ip:$port push alive.txt data/
    else
        #echo "adb push failed, network does not work!"
        break
    fi
done

adb devices | grep "$ip:$port"
if [[ $? -eq 0 ]];then
    adb disconnect $ip:$port
fi
exit    
