Quellen:

- <https://www.youtube.com/watch?v=b4vTKg-qW_0>
- <https://rootco.de/2018-01-19-opensuse-btrfs-subvolumes/>


# Installation

## Command line

Execute commands between partitioning and installing

```shell

umount /target/boot/efi
umount /target/boot
umount /target

mount /dev/mapper/<dmcrypt_partition> /mnt

ls /nnt
mv /mnt/@rootfs /mnt/@

# btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@/.snapshots

mkdir /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot

#mkdir -p /mnt/@/boot/grub2/
#btrfs subvolume create /mnt/@/boot/grub2/i386-pc
#btrfs subvolume create /mnt/@/boot/grub2/x86_64-efi

btrfs subvolume create /mnt/@/home
btrfs subvolume create /mnt/@/opt
btrfs subvoulme create /mnt/@/root
btrfs subvolume create /mnt/@/srv
btrfs subvolume create /mnt/@/tmp

mkdir /mnt/@/usr/
btrfs subvolume create /mnt/@/usr/local
btrfs subvolume create /mnt/@/var

#chattr +C /mnt/@/var


nano /mnt/@/.snapshots/1/info.xml
#-------------------------------------------------
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>$DATE</date>
  <description>first root filesystem</description>
</snapshot>
#-------------------------------------------------

#btrfs subvolume set-default $(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /mnt
btrfs subvolume list /mnt
btrfs subvolume set-default 258 /mnt
unmount /mnt

mount -o subvol
mount /dev/sda1 /mnt

mount -o subvol=@,noatime,compress=zstd:1 /dev/mapper/<dmcrypt_partition> /target

mkdir -p /target/.snapshots
#mkdir -p /target/boot/grub2/i386-pc
#mkdir -p /target/boot/grub2/x86_64-efi
mkdir -p /target/boot/efi
mkdir -p /target/home
mkdir -p /target/opt
mkdir -p /target/root
mkdir -p /target/srv
mkdir -p /target/tmp
mkdir -p /target/usr/local
mkdir -p /target/var

mount /dev/mapper/<dmcrypt_partition> /target/.snapshots -o subvol=@/.snapshots,noatime,compress=zstd:1
#mount /dev/mapper/<dmcrypt_partition> /target/boot/grub2/i386-pc -o subvol=@/boot/grub2/i386-pc,noatime,compress=zstd:1
#mount /dev/mapper/<dmcrypt_partition> /target/boot/grub2/x86_64-efi -o subvol=@/boot/grub2/x86_64-efi,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/home -o subvol=@/home,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/opt -o subvol=@/opt,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/root -o subvol=@/root,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/srv -o subvol=@/srv,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/tmp -o subvol=@/tmp,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/usr/local -o subvol=@/usr/local,noatime,compress=zstd:1
mount /dev/mapper/<dmcrypt_partition> /target/var -o subvol=@/var,noatime,compress=zstd:1

mount /dev/<boot_partition> /target/boot
mount /dev/<efi_partition> /target/boot/efi


nano /target/etc/fstab
#-------------------------------------------------
/dev/maper/<dmcrypt_partition> /             btrfs    subvol=@,noatime,compress=zstd:1              0    0
/dev/maper/<dmcrypt_partition> /.snapshots   btrfs    subvol=@/.snapshots,noatime,compress=zstd:1   0    0
/dev/maper/<dmcrypt_partition> /home         btrfs    subvol=@/home,noatime,compress=zstd:1         0    0
/dev/maper/<dmcrypt_partition> /opt          btrfs    subvol=@/opt,noatime,compress=zstd:1          0    0
/dev/maper/<dmcrypt_partition> /root         btrfs    subvol=@/root,noatime,compress=zstd:1         0    0
/dev/maper/<dmcrypt_partition> /srv          btrfs    subvol=@/srv,noatime,compress=zstd:1          0    0
/dev/maper/<dmcrypt_partition> /tmp          btrfs    subvol=@/tmp,noatime,compress=zstd:1          0    0
/dev/maper/<dmcrypt_partition> /usr/local    btrfs    subvol=@/usr/local,noatime,compress=zstd:1    0    0
/dev/maper/<dmcrypt_partition> /var          btrfs    subvol=@/var,noatime,compress=zstd:1          0    0

UUID=<GUID_boot_partition>     /boot         ext4     defaults       0    2

UUID=<GUID_efi_partition>      /boot/efi     vfat     umask=0077    0    1
#-------------------------------------------------


unmount /mnt

```

# Post-Installation


## Disable copy-on-write at /var

```shell
sudo mount /dev/mapper/<dmcrypt_partition> /mnt -o subvolid=5
sudo chattr +C /mnt/@/var
sudo umount /mnt
```

# Enable zram

```shell
sudo apt install zram-tools

sudo nano /etc/default/zramswap
#-------------------------------------------------
PERCENT=50
#-------------------------------------------------

sudo systemctl restart zramswap.service
```

# Cutomize boot settings

```shell
sudo apt install firmware-linux plymouth-themes

sudo nano /etc/default/grub
#-------------------------------------------------
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 splash"
#-------------------------------------------------

sudo update-grub2

sudo apt install snapper-gui git inotify-tools


sudo mv /.snapshots /.snapshots.bkp
sudo snapper -c root create-config /
sudo rm -rf /.snapshots
sudo mv /.snapshots.bkp /.snapshots

sudo snapper -c root set-config "TIMELINE_CREATE=no"
sudo snapper -c root set-config "ALLOW_GROUPS=sudo"
sudo snapper -c root set-config "SYNC_ACL=yes"

nano /etc/snapper/configs/root
#-------------------------------------------------
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
#-------------------------------------------------


sudo snapper -c home create-config /home

sudo snapper -c home set-config "TIMELINE_CREATE=no"
sudo snapper -c home set-config "ALLOW_GROUPS=sudo"
sudo snapper -c home set-config "SYNC_ACL=yes"

nano /etc/snapper/configs/root
#-------------------------------------------------
#-------------------------------------------------
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
#-------------------------------------------------

sudo systemctl disable snapper-boot.timer



cd ~
sudo git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
make install
sudo systemctl enable --now grub-btrfsd
sudo systemctl status grub-btrfsd
cd ~
rm -rf grub-btrfs




```
