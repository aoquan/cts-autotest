#!/bin/bash  -x
isoLoc=$1 

#user="root"
#cp2host="aquan@192.168.2.39:/"
#cp2port="22"

testingUser="root"
testingIP="166.111.131.12"
testingPort="6622"
testingFold="/home/oto/cts"

testedUser="oto"
testedIP="166.111.131.12"
testedPort="7022"
testedFold=""

localUser="aquan"



scp -P $testingPort $isoLoc $testingUser@$testingIP:$testingFold
ssh -p $testingPort $testingUser@$testingIP $testingFold/cts-autotest/testAll.sh
#scp -P 11281 /home/oto/cts/android-cts/repository/results/*.zip /home/aquan/ 

