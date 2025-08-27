# intel-ultra-rom
build ROM files for Intel Ultra 1th-2th Gen iGPU passthrough in PVE VMs（intel ultra 1-2代pve虚拟机核显直通使用rom）

intel 6-14代pve虚拟机核显直通请使用 https://github.com/lixiaoliu666/intel6-14rom

intel ultra 1-2代pve虚拟机核显直通使用rom 使用说明，只支持qemu 10及以上（不支持qemu 7 8 9）

dpkg -l|grep kvm 运行这个命名，查看qemu版本，下面的10.0.2-1代表qemu 10 

ii pve-qemu-kvm             10.0.2-4              amd64    Full virtualization on x86 hardware

可以使用我的项目 https://github.com/lixiaoliu666/pve-anti-detection 的10.0版本deb实现q35有bios画面pve核显直通。

交流qq群 25438194（666)

一、关于虚拟机机型设置：

intel核显直通ultra 1-2代统一使用ovmf+i440fx机型（i440fx至少10.0以上到最新都可以），当然也支持ovmf+q35 10（详细请看 https://www.bilibili.com/read/cv41702099 ）

二、关于编译源码：

如果你不想编译直接使用，请在Build文件夹中直接使用ultra-1-2-qemu10.rom就是

2.1 编译准备工作：

可以直接fork本项目后点Actions进行云编译，也可以下面步骤下载到本地编译。

①、首先下载本项目

git clone https://github.com/lixiaoliu666/intel-ultra-rom 可能会断掉，请多试几次。你可以使用代理加速（如何切换git clone后的版本自行百度）。 因为只使用编译后的efi以及生成的rom

②、进入intel-ultra-rom目录运行一下 bash build_efi_rom.sh 成功

③、到Build目录进行操作，合并出来具体型号的rom或者cmdrom.bat 参考build_efi_rom.sh 最后一行命令

或者你在windows上直接双击运行 cmdrom.bat 就是，
Build目录下的是生成rom必备的各种efi文件及efirom（efirom.exe）

2.2 如何使用

①、nano /etc/default/grub 文件中增加内容add text GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"

②、nano /etc/modprobe.d/pve-blacklist.conf 文件中增加内容add text

blacklist i915

blacklist snd_hda_intel

options vfio_iommu_type1 allow_unsafe_interrupts=1

③、执行下面三个命令run the following three commands

update-grub

update-initramfs -u -k all

reboot

④、新建win虚拟机并修改虚拟机参数（nano /etc/pve/qemu-server/100.conf ）为类似下面：

args: -set device.hostpci0.addr=02.0 -set device.hostpci0.x-igd-gms=0x2 -set device.hostpci0.x-igd-opregion=on -set device.hostpci0.x-igd-legacy-mode=on

bios:ovmf

cpu: host

hostpci0: 0000:00:02.0,romfile=ultra-1-2-qemu10.rom

hostpci1: 0000:00:1f.3

vga: none

machine: pc-i440fx-10.0

选择 ovmf+机型i440fx 10.0以上就是 0000:00:02.0是核显的pci编号

0000:00:1f.3是声卡的pci编号

ultra-1-2-qemu10.rom这个文件请用winscp等软件传输到/usr/share/kvm/ 目录下

当然unraid也可以使用ultra-1-2-qemu10.rom

参数解释Parameter Explanation：

1⃣️x-igd-opregion=on：实现物理输出，它是实验性的（x代表experimental实验性的，官方不支持就一直是实验性）（The x-igd-opregion property exposes opregion (VBT included) to guest driver so that the guest driver could parse display connector information from. This property mandatory for the Windows VM to enable display output.）

2⃣️x-igd-gms=0x2代表使用核显预分配显存大小，解决虚拟机内存占用过大问题，这个要大于bios中的核显显存大小，源码是gms * 32 * MiB;这样计算的，0x1代表32M，0x2=64M，0x3=96M，0x4=128M，0x5=160M，0x6=192M，0x7=224M，0x8=256m，0x9=288M，0x10=320M，0xf0=5120M（The x-igd-gms property sets a value multiplied by 32 as the amount of pre-allocated memory (in units of MB) to support IGD in VGA modes.）

3⃣️legacy-igd=1这个是pve私有参数（其他没这个参数比如unraid）让核显Legacy模式显示画面

④ x-igd-legacy-mode=on Enable/Disable legacy mode，这个是qemu10才有的通用参数，完全可以 x-igd-legacy-mode=on替代pve的legacy-igd=1私有参数

参数解释详见refer to https://eci.intel.com/docs/3.3/components/kvm-hypervisor.html Passthrough KVM Graphics Device部分sub

2.3 虚拟机开机点不亮bios画面

①、检查下你虚拟机配置如上类似

②、可能我的rom里面没有增加你机器的IntelGopDriver.efi，你使用2.5步骤 获取到你机器的bios，然后使用2.4提取出来IntelGopDriver.efi文件。然后放到\Build目录下，你照着 cmdrom.bat 这个程序增加IntelGopDriver.efi改出来命令行，自己合成rom就是。

③、合并了新的ultra-1-2-qemu10.rom你直接用就是

2.4、IntelGopDriver.efi如何得来

①、用ubu提取物理bios的IntelGopDriver.efi

UBU 1.79.17下载地址：https://pan.baidu.com/s/1pD7NqJoOThQawJw59NyTHQ 提取码: ivwk

②、物理bios可以到华擎官网下载 https://www.asrockind.com/zh-cn/single-board-computer

里面各个类目都点开试试，?SBC?UTX?NUC等等，intel和amd型号都有哦

③、使用mmtool也可以提取

2.5 物理机的bios如何得来

①、到你机器的官网去下载

②、用AMI bios（ami固件）提取工具 直接提取 类似教程详见 https://www.bilibili.com/read/cv25423474/ 提取物理机bios 部分

