<<<<<<< HEAD
# openthos在bare-metal上的自动测试

##测试对象，以及设计原理说明
* PC1  
PC1为测试对象,上面安装了linux和android_x86双系统  
linux系统的作用跟android手机的fastboot功能是一样的，用来刷系统，或者更新系统中的一个分区。

 PC1上面的linuxOS安装到了/dev/sda2,android安装到了/dev/sda40【可以通过配置文件指定】,ESP分区为/dev/sda1,测试程序中的参数也是这么设定的(见原理图)。如果想变换分区，需要修改*.sh中对应的参数，程序注释中也给出了提示。   
* PC2  
PC2为是存放程序和数据的地方，用于远程控制PC1  
而且可以通过修改auto2.sh配置文件中的以下两个参数达到控制多台设备的效果。不同的设备对应不同的IP地址。  
ip_linux="192.168.2.16"【PC1的IP地址】  
ip_android="192.168.2.58"【PC1上面的android IP地址】  

* 特点：
 1. 【fastboot for androidx86】模拟了android 中的fastboot功能，参数也很相似，通用于测试android手机设备。  
 2. 【kickstart for androidx86】利用kickstart的无人值守安装机制，结合【fastboot for androidx86】实现了androidx86在baremetal下面的无人值守安装。
 2. 使用rsync可以方便的同步脚本和数据，而且是增量的，而且可执行权限也不需要加，由于是镜像的，所以排错很容易。本地测试远程测试都很方便 
 3. 一份代码，只需要修改配置文件，即可同时应用于远程控制多台设备。  


* 工作原理图  
![Aaron Swartz](https://raw.githubusercontent.com/xyongcn/openthos-testing/master/bare_metal_autotest/android_auto/android_x86%E7%9C%9F%E5%AE%9E%E6%9C%BA%E5%99%A8%E8%87%AA%E5%8A%A8%E6%B5%8B%E8%AF%95%E6%A1%86%E6%9E%B6.JPG)

##PC1初始化环境


1.  安装64位ubuntu（要求15.10及以上，因为14.04以前的版本中fdisk不支持操作gpt格式的磁盘）  
在UEFI中关闭cms选项，即把传统的BIOS功能关掉，只使用uefi模式</br>
硬盘分区必须是gpt格式</br>
以UEFI形式安装ubuntu到/dev/sda2</br>
esp分区为/dev/sda1</br>
auto2.sh程序会根据配置参数自动创建10G的分区，用于安装androidx86 
apt-get install squashfs-tools【安装 squashfs-tools】

2. 把PC1启动到linux，等待接收PC2的测试指令


##PC2初始化环境
1.  在ubuntu部署ssh无密码登录  
以root 登录，执行以下命令  
ssh-keygen  
ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.200.10[pc1的ip地址]  

1.  将git中bare_metal_autotest下面的android_auto/目录移动到PC2上的/root/目录下面



##PC2进行一轮自动化测试
1.  cd /root/android_auto
修改auto2.sh文件中的配置参数。  
ip_linux="192.168.2.16"【PC1的IP地址】  
ip_android="192.168.2.58"【PC1上面的android IP地址】  
android_iso_for_test="/root/android_x86.iso_xly_5.1"【要测试的androidx86  ISO的全路径及文件名】  
diskpart_for_android="/dev/sda40"【PC1上面的要安装android的目标分区】  


2. 提供要测试的ISO文件到android_iso_for_test参数指定的位置

3.  运行 
./auto2.sh进行一轮自动化测试

4.  auto2.sh是一个测试过程的举例，
演示了本目录中的各个脚本提供的服务如何使用。以及如何使用这些服务完成一个系统安装，app运行测试。
例如重装android系统,启动到android，安装一个apk,启动apk,测试用例自己记录测试中间结果到约定目录，重启android,测试完毕。
5.  本测试框架只提供机制不提供策略，如果要加新的测试过程，只需要仿照auto2.sh脚本进行修改即可。


##BUG REPORT
如有bug欢迎反馈，讨论、交流。
=======
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

  `sudo ./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no ../../android-x86/android_x86.iso`

1. 如果安装android-x86,安装完毕android-x86之后，用下面命令来启动qemu

  `sudo ./qemu-system-x86_64 -m 4G --enable-kvm -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no -vga std -serial stdio -hda ../../android_x86.raw`

##android-x86的ip地址
可以在android中的setting --> about table --> status 看到ip地址信息
 
##设置qemu的网络桥接模式
```
for we use regular expression to  get ipaddress, in order to avoid mistakes, we should change our system language into English, both root and normal user
change /etc/default/locale
```
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
```

now we change network bridge to NAT, so the content below is useless
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
>>>>>>> 21774a893c6691b4760af95ad706c46c74a054ee

