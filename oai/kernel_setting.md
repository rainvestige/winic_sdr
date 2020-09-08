# Kernel Setting
- ref
    1. [kernel](https://blog.csdn.net/FoxBryant/article/details/104777579) 
 

## 显示内核的顺序

命令
```bash
cat /boot/grub/grub.cfg | awk -F"--" '$0 ~ /menuentry/ {print $1}'
```

结果(序号从0开始)
```bash
menuentry 'Ubuntu, with Linux 5.3.0-63-lowlatency'
menuentry 'Ubuntu, with Linux 5.3.0-63-lowlatency (recovery mode)'
menuentry 'Ubuntu, with Linux 5.3.0-63-generic'
menuentry 'Ubuntu, with Linux 5.3.0-63-generic (recovery mode)'
menuentry 'Ubuntu, with Linux 5.3.0-62-lowlatency'
menuentry 'Ubuntu, with Linux 5.3.0-62-lowlatency (recovery mode)'
menuentry 'Ubuntu, with Linux 5.3.0-62-generic'
menuentry 'Ubuntu, with Linux 5.3.0-62-generic (recovery mode)'
menuentry 'Ubuntu, with Linux 4.15.0-112-lowlatency'
menuentry 'Ubuntu, with Linux 4.15.0-112-lowlatency (recovery mode)'
menuentry 'Windows Boot Manager (on /dev/nvme0n1p2)'
menuentry 'System setup' $menuentry_id_option 'uefi-firmware' {
```


## 修改内核默认启动顺序

命令
```bash
sudo vim /etc/default/grub

# Change the value of `GRUB_DEFAULT` from 0 to the number you want
# According to my setting, i will choose the 'Windows Boot Manager' as my 
# default boot entry.
```

修改内容
```bash
GRUB_DEFAULT=10
```

## Update grub

```bash
sudo update-grub
```

## Reboot

```bash
uname -r

```


## Uninstall Kernel

```bash
dpkg --get-selections | grep linux | awk '$2 ~ /^install/ {print $0}'

sudo apt-get remove linux-image-***-***
sudo apt-get remove linux-headers-***-***
sudo apt-get remove linux-modules-***-***

sudo update-grub

dpkg --get-selections | grep linux | awk '$2 ~ /^install/ {print $0}'
```
