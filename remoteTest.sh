#!/bin/bash 
isoLoc=$1
scp -P 6622 $isoLoc oto@166.111.131.12:/home/oto/cts/
./testAll.sh 
scp -P 11281 /home/oto/cts/android-cts/repository/results/*.zip /home/aquan/ 

