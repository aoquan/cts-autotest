# openthos在bare-metal上的自动测试

##测试对象说明
* PC1  
PC1为测试对象,上安装了linux和android_x86双系统  
PC1上面的linuxOS安装到了/dev/sda1, android 安装到了/dev/sda2,ESP分区为/dev/sda4,测试程序中的参数也是这么设定的(注意和原理图中的分区举的例子不一样)。如果想变换分区，需要修改*.sh中对应的参数，程序注释中也给出了提示。   
* PC2  
PC2为是存放程序和数据的地方，用于远程控制PC1   
使用rsync可以方便的同步脚本和数据，而且是增量的  
而且可执行权限也不需要加，由于是镜像的，所以排错很容易。本地测试远程测试都很方便

* 工作原理图  
![Aaron Swartz](https://raw.githubusercontent.com/xyongcn/openthos-testing/master/bare_metal_autotest/android_auto/android_x86%E7%9C%9F%E5%AE%9E%E6%9C%BA%E5%99%A8%E8%87%AA%E5%8A%A8%E6%B5%8B%E8%AF%95%E6%A1%86%E6%9E%B6.JPG)

##PC1初始化环境


1.  安装64位ubuntu（14.04及以上）  
在UEFI中关闭cms选项，即把传统的BIOS功能关掉，只使用uefi模式</br>
硬盘分区必须是gpt格式</br>
以UEFI形式安装ubuntu到/dev/sda1</br>
esp分区为/dev/sda4</br>
划分10G左右分区/dev/sda2,并格式为ext4用于安装android  
2. 把PC1启动到linux，等待接收PC2的测试指令


##PC2初始化环境
1.  在ubuntu部署ssh无密码登录  
以root 登录，执行以下命令  
ssh-keygen  
ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.200.10[pc1的ip地址]  

1.  将git中bare_metal_autotest下面的android_auto/目录复制到PC2上的/root/目录下面
3.  cd /root/android_auto  
4.  只执行一次./android_tool.sh ${ip_linux} android_x86_uefi_install.sh  
其中${ip_linux}替换为PC1的IP地址


##PC2进行一轮自动化测试
1.  cd /root/android_auto
2.  替换android_x86.iso为真实的iso文件
3.  运行 
./android_auto.sh进行一轮自动化测试  
根据提示输入ip_linux即PC1上面的linuxOS对应的IP地址  
根据提示输入ip_android即PC1上面的androidOS对应的IP地址
4.  android_auto.sh是一个测试过程的举例，例如重装android系统,启动到android，安装一个apk,启动apk,测试用例自己记录测试中间结果到约定目录，重启android,测试完毕。
5.  本测试框架只提供机制不提供策略，如果要加新的测试过程，只需要仿照android_auto.sh脚本进行修改即可。
