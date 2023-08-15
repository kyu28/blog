# 在ARM设备上的Linux运行x86(x86_64) Windows程序
*注意本文与远程桌面无关*  

---

## 前言
众所周知ARM与x86并不是同一个架构，其机器语言不同，程序无法直接在对方的机器上运行  
众所周知Linux与Windows的可执行文件格式不同，系统调用也不同，程序无法直接在对方的系统上运行  
  
如何使x86架构下的Windows程序在ARM架构下的Linux运行？  
最直接的思路就是使用虚拟机虚拟一个完整的x86 Windows *（快感谢万能的QEMU）*  
理论可行而且兼容性应当不错，但是要虚拟一个系统内核，额外的开销太大  
于是普遍采用的方法是**转译**  
  
故解决问题需要两个步骤：  
1. 将Windows的程序转译为Linux可执行的指令
2. 将x86机器指令转译为ARM架构机器指令
  
*我才不会说是为了拿安卓平板玩游戏才折腾这个的*

---

## 运行环境
Raspberry Pi OS (64Bit) (bullseye) @ Raspberry Pi 4B 2GB
Termux 0.118.0 on Android 12 @ Lenovo TB138FC

---

## 方案
关于第一个步骤（Windows转译为Linux）开源社区已有相对成熟的方案--  
**Wine**
故以下多个方案均离不开Wine  
PS: V社在Wine的基础上开发了Proton兼容层 *（没错就是Steam Deck用的那个）*，是否可在方案中结合Proton兼容层留给读者自证

关于第二个步骤（x86转译为ARM）则有多个方案  
1. ExaGear  
若之前折腾过安卓跑Windows应用的应该对这个工具有些印象，随着2019年其原开发的俄罗斯公司ElTechs宣布停止开发后，2020年由华为收购继续开发，自称“华为自研动态二进制翻译工具”  
至今其依然在众多机关单位国产化后普及的ARM64架构的UOS系统设备上用于运行QQ等Windows应用  
[原始ExaGear，具体使用留给读者自证](https://www.hikunpeng.com/zh/developer/devkit/exagear)  
[ExaGear for Termux](https://github.com/ZhymabekRoman/Exagear-For-Termux)  

2. QEMU User Emulation  
利用Linux内核的binfmt_misc机制将x86程序通过QEMU打开并透明运行

3. Box86 & Box64  
GitHub上的开源项目  
[Box86](https://github.com/ptitSeb/box86)  
[Box64](https://github.com/ptitSeb/box64)  
面向ARM的x86转译  

---

## QEMU User Emulation
**成功在树莓派上运行程序**  
**成功在安卓上部署，但是未能稳定运行程序**  
`Linux(ARM) --QEMU, chroot/proot--> Linux(x86) --Wine--> Windows EXE(x86)`  
在这个方案中，我们要先创建一个x86的Linux文件系统，通过chroot/proot进入该文件系统，并在该文件系统下运行Wine  
  
*chroot还是proot？*  
*如果有root权限，建议chroot，若无root权限这个问题也不会提出来了*  
*proot利用ptrace机制实现来劫持系统调用和返回值，性能上较chroot更差*  
*chroot需要root权限，而proot不需要*  

步骤：   
1. 宿主机安装qemu-user  
建议使用qemu 7以上否则可能会出现Segmentation Fault，Debian可以在Sid源中找到qemu 8  
以上述树莓派环境为例  
`apt install qemu-user-static`  
  
2. 宿主机下载部署x86 Linux的文件系统  
可以使用debootstrap，也可以手动下载解压其他发行版的文件系统，但是一定要x86（或i386）的  
如果要执行64位程序则把后面看到的x86/i386全部替换成x86_64（或amd64）  
  
3. 切换至x86 Linux的文件系统  
+ 使用chroot  
```
cd <x86 Linux的文件系统>
cp /usr/bin/qemu-i386-static ./usr/bin # 32位系统用这个
cp /usr/bin/qemu-x86_64-static ./usr/bin # 64位系统用这个
# 下列mount极其重要
mount --bind /dev ./dev
mount --bind  /dev/pts ./dev/pts
mount -t proc /proc ./proc
mount --bind /etc/resolv.conf ./etc/resolv.conf
mount -t sysfs /sys ./sys
mount --bind /dev/shm  ./dev/shm
chroot ./
```
  
+ 使用proot  
```
apt install proot
cd <x86 Linux的文件系统> 
proot -S ./ -q qemu-i386-static # 32位系统用这个 
proot -S ./ -q qemu-x86_64-static # 64位系统用这个 
```
  
4. x86文件系统内安装Wine  
按发行版的步骤安装Wine即可  
例如`apt install wine`  
  
5. 设定输出屏幕并运行Wine  
宿主机执行`xhost +`以允许chroot/proot内的程序显示到你的屏幕上  
x86环境内执行  
```
export DISPLAY=:0
winecfg
```
若Wine的配置界面正确出现则配置成功  

---

## Box86 & Box64
**安卓上成功稳定运行程序**  
*下列描述基于Android，需要安装Termux*  
```
Linux(ARM) --Box86 + Wine---> Windows EXE(x86)
    |
    +--------Box64 + Wine64-> Windows EXE(x64)
```
在该方案中，我们使用Box86/Box64直接转译运行x86/x86_64的Wine以转译运行Windows程序  
Box86仅能运行32位程序，Box64仅能运行64位程序  
  
*太长不看版：文末有自动化脚本实现Termux部署Box86 & Box64*  
  
0. 仅Termux需要处理的操作  
我们需要为程序的显示、音频输出、硬件加速做一些前置工作  
*毕竟在容器里难以直接用Android的显示和音频系统*  
```
apt install x11-repo
apt install termux-x11-nightly pulseaudio virglrenderer-android
```
Android中安装[Termux:X11 App](https://github.com/termux/termux-x11)以作为显示屏  
  
同时Termux的基础系统软件包以及依赖等问题不适合作为基础系统，故尝试proot（chroot方法留作读者自证）  
```
apt install proot-distro # proot的封装脚本，使用更方便
proot-distro install debian # 此处以Debian为例
proot-distro login debian --shared-tmp # 只有共享tmp文件夹才能找到本机的DISPLAY
```
  
后续使用时均需要进行如下操作  
```
termux-x11 :0 & # 启动屏幕
virgl_test_server_android & # 启用硬件加速服务
# 启用音频服务
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
```

1. 在系统中安装Box86 & Box64  
如果使用Debian系的系统就有福了，可以使用编译好的deb包：  
```
curl -L https://ryanfortner.github.io/box64-debs/box64.list -o /etc/apt/sources.list.d/box64.list
curl -L https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
curl -L https://ryanfortner.github.io/box86-debs/box86.list -o /etc/apt/sources.list.d/box86.list
curl -L https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
dpkg --add-architecture armhf # Box86只可运行在32位的armhf架构中
apt update
apt install -y box64-android libc6:armhf box86-android:armhf # Box86需要32位运行环境故有libc6:armhf
```
  
若不想使用或无法使用编译好的deb包可以按照Box86和Box64官方的编译指南自行编译程序：  
[Box86编译指南](https://github.com/ptitSeb/box86/blob/master/docs/COMPILE.md)  
[Box64编译指南](https://github.com/ptitSeb/box64/blob/main/docs/COMPILE.md)  
  
安装Box86 & Box64所需依赖：  
修改自[Box64 Wine安装指南](https://github.com/ptitSeb/box64/blob/main/docs/X64WINE.md#examples)  
```
apt install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
  libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libldap-common:armhf libopenal1:armhf libpcap0.8:armhf \
  libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
  libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libncurses5:armhf libcap2-bin:armhf libcups2:armhf \
  libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
  libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc1:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
  libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
  libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
apt install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
  libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libldap-common:arm64 libopenal1:arm64 libpcap0.8:arm64 \
  libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
  ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
  libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
  libgssapi-krb5-2:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
  libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
  libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
```

2. 安装Wine（i386和amd64）  
**注意不是armhf和aarch64版本**  
*Box86只能执行i386程序，Box64只能执行amd64程序，armhf和aarch64它们不管*  
  
我们可以从Wine官网上下载编译好的程序（或者使用[清华的镜像站](https://mirrors.tuna.tsinghua.edu.cn/wine-builds/)）  
下载完后安装部署（此处以Debian为例，即`dpkg-deb -x`）  
下列示例修改自[Box64 Wine安装指南](https://github.com/ptitSeb/box64/blob/main/docs/X64WINE.md#examples)  
```
MIRROR=mirrors.tuna.tsinghua.edu.cn
LNKA="https://${MIRROR}/wine-builds/${id}/dists/${dist}/main/binary-amd64/" # amd64-wine links
DEB_A1="wine-${branch}-amd64_${version}~${dist}${tag}_amd64.deb" # wine64 main bin
DEB_A2="wine-${branch}_${version}~${dist}${tag}_amd64.deb" # wine64 support files (required for wine64 / can work alongside wine_i386 main bin)
LNKB="https://${MIRROR}/wine-builds/${id}/dists/${dist}/main/binary-i386/" # i386-wine links
DEB_B1="wine-${branch}-i386_${version}~${dist}${tag}_i386.deb" # wine_i386 main bin
#DEB_B2="wine-${branch}_${version}~${dist}${tag}_i386.deb" # wine_i386 support files (required for wine_i386 if no wine64 / CONFLICTS WITH wine64 support files)

# Install amd64-wine (64-bit) alongside i386-wine (32-bit)
echo "Downloading and extracting wine"
curl -O ${LNKA}${DEB_A1}
dpkg-deb -x ${DEB_A1} wine-installer &
curl -O ${LNKA}${DEB_A2}
dpkg-deb -x ${DEB_A2} wine-installer &
curl -O ${LNKB}${DEB_B1}
dpkg-deb -x ${DEB_B1} wine-installer
echo "Installing wine"
[ ! -d "/opt" ] && mkdir /opt
mv wine-installer/opt/wine* /opt/wine
rm -rf wine-installer *.deb
```
  
至此Wine安装到了`/opt/wine`中，可以准备运行Windows的EXE了  
  
3. 运行EXE  
在运行之前需要告诉系统显示到哪里，音频播放到哪里，用不用硬件加速等  
```
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1:4713 # Termux要用这个，因为音频服务不在容器内
export BOX86_PATH=/opt/wine/bin # Box86所使用的PATH，其将在这个路径中查找所运行的程序
export GALLIUM_DRIVER=virpipe # 使用硬件加速，部分应用不使用硬件加速无法启动
export MESA_GL_VERSION_OVERRIDE=4.0 # 强制使用OpenGL 4.0，可能导致部分应用无法启动
```
  
准备就绪就可以准备启动应用了  
```
# 32位系统
box86 wine winecfg
# 64位系统
box64 wine64 winecfg
```
  
如果使用了Termux:X11则打开该App，应该可见EXE成功运行  

+ Box86 & Box64 Termux自动化脚本  
[宿主机执行脚本](resources/setup-termux-wine.sh)  
[容器内安装脚本](resources/install-box86-wine.sh)  
下载上述脚本至Termux中并置于同一路径下，执行宿主机执行脚本`./setup-termux-wine.sh`即可完成安装  
安装[Termux:X11 App](https://github.com/termux/termux-x11)后  
1. 运行`./startx11d`  
2. 运行`./startproot`进入PRoot容器  
3. 找到要运行的应用并`/opt/box86wine 32 <EXE名>`即可运行32位应用，`/opt/box86wine 64 <EXE名>`即可运行64位应用  

---

## 拓展阅读
[如何在树莓派（或其他arm计算机）跑x86 windows的软件？](https://zhuanlan.zhihu.com/p/272268520)  
[cheadrian/termux-chroot-proot-wine-box86_64](https://github.com/cheadrian/termux-chroot-proot-wine-box86_64)  
[Termux以virglrenderer達成GPU 3D硬體加速](https://ivonblog.com/posts/termux-virglrenderer/)  
[Termux Proot安裝Box64與Box86，Android手機執行Windows exe | Ivon的部落格](https://ivonblog.com/posts/termux-proot-box86-box64/)  