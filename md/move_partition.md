# Linux于终端移动硬盘分区指南
*以ext4为例*  
**图形界面请直接使用gparted**  
全文括号（）括起内容需替换为实际操作的对应值

---

## 0.获取盘符和分区号
*你可能需要root权限，sudo是个好东西*
`fdisk -l`  
见输出，Device行下即为具体分区表  
```
（前略）
Device     Boot     Start       End   Sectors   Size Id Type
/dev/sda1            2048 488384511 488382464 232.9G  7 HPFS/NTFS/exFAT
/dev/sda2       488384512 976769023 488384512 232.9G  7 HPFS/NTFS/exFAT
```
`sda1`即为一个带盘符的分区号实例，sda是盘符，1是这个分区在sda盘上的分区号  
`Start`代表这个分区的起始block（起始块），`End`代表结束block  
`Size`即大小，`Type`是分区表中标记的分区类型  
带盘符分区号还可能长`nvme0n1p3`、`sdb2`、`mmcblk0p4`这些样子，取决于硬件类型  

---

## 0.5.重新规划大小（选做）
```
e2fsck -f /dev/（带盘符分区号）
resize2fs /dev/（带盘符分区号） (新的大小)
```

---

## 1.移动分区
*依赖sfdisk，通常在util-linux包中提供*  
`echo "（方向）（距离）," | sfdisk --move-data /dev/（盘符） -N (分区号)`  
例`echo "+100M," | sfdisk --move-data /dev/sda -N 2`  
正方向表示向后（高位）移动，负方向反之  

---

## 2.在fdisk中对分区重新划分大小和定位
**不是sfdisk，虽然似乎也可以实现相同功能……**  
以下操作中//代表注释，并非实际需输入的指令
```
fdisk
//按d，进行删除分区操作）
d
//在此步中务必记忆这个分区的起始block，非常重要！
（需要重新规划大小的分区的分区号）
//按n，进行创建分区操作
n
（随意选择一个可用的分区号）
（刚刚记忆的起始block）
//不要漏掉+号，这里是指在起始block基础上加上输入的空间
+（新的大小）
//按w，对硬盘写入刚刚规划的操作
w
```
