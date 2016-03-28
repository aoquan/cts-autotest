# cts-autotest
##安装android-x86
关于安装android-x86,参考https://github.com/xyongcn/openthos-testing/blob/master/doc/Openthos4Qemu2016.md
##安装jdk
测试机需要安装jdk1.6或者1.7，不支持1.8

##在真机中测试
1. 运行脚本需要指定android-x86的ip地址和端口号
1. autoTest.sh脚本与cts-tradefed脚本需要放在同一个目录下面
1. 目前autoTest.sh会自动测试默认的plan(CTS)
1. 测试举例：./autoTest.sh 192.168.2.51:5555

##在模拟器中测试
1. 模拟器（qemu）中的测试方法与真机上一致，但模拟器中需要设置qemu的桥接模式
1. 运行qemu的命令为（非安装,使用iso）:

`./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso`

1. 如果安装android-x86,安装完毕android-x86之后，用下面命令来启动qemu

`sudo ./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no -vga std -serial stdio -hda ../../android_x86.raw`

##android-x86的ip地址
可以在android中的setting --> about table --> status 看到ip地址信息
 
##设置qemu的网络桥接模式
```
对/etc/network/interfaces文件进行修改
改成如下即可
auto eth0
iface eth0 inet manual
auto tap0
iface tap0 inet manual
up ifconfig IFACE 0.0.0.0 up 
down ifconfig IFACE 0.0.0.0 up 
down ifconfig IFACE down
tunctl_user aquan      
#aquan是我的用户名，在这里换为你的用户名
auto br0
iface br0 inet dhcp
bridge_ports eth0 tap0
#这里我们使用dhcp,当然也可以配置成静态的（未实验）
#auto br0
#iface br0 inet static      
#bridge_ports eth0 tap0
#address 192.168.2.45
#netmask 255.255.255.0
#gateway 192.168.2.1
```
