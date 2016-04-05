#!/bin/bash
# 先把ssh client端的东西rsync到ssh server端。
# 然后执行
# x86tool ip  fastboot
# 其实就是
# ssh  {ip} exec  argv[1-end]
# 利用ssh rsync同步本地的东西到远端。
# 或者sftp也行，然后实现命令的转发
rip=$1
arg_s=${@:2} 
#rsync  --delete  -avz -e ssh ../android_auto/   root@${rip}:~/android_auto/
rsync   -avz -e ssh ./autoFrame/ root@${rip}:~/android_auto/
ssh root@${rip} "~/android_auto/${arg_s}"
