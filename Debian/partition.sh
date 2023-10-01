#!/bin/bash

# https://raw.githubusercontent.com/akurpanek/esmeralda/main/Debian/partition.sh

devroot=$(awk '$2 == "/target" {print $1}' /proc/mounts)
devboot=$(awk '$2 == "/target/boot" {print $1}' /proc/mounts)
devuefi=$(awk '$2 == "/target/boot/efi" {print $1}' /proc/mounts)

#read -p 'Press [Enter] key to continue...'

idroot=$(blkid -o value -s UUID $devroot)
idboot=$(blkid -o value -s UUID $devboot)
iduefi=$(blkid -o value -s UUID $devuefi)

#read -p 'Press [Enter] key to continue...'

echo 'root='$devroot' ('$idroot')'
echo 'boot='$devboot' ('$idboot')'
echo 'ueif='$devuefi' ('$iduefi')'

#read -p 'Press [Enter] key to continue...'

#umount $devuefi
#umount $devboot
#umount $devroot

#read -p 'Press [Enter] key to continue...'

#mount $devroot /mnt

#read -p 'Press [Enter] key to continue...'

#mv /mnt/@rootfs /mnt/@

#read -p 'Press [Enter] key to continue...'

##btrfs subvolume create /mnt/@
#btrfs subvolume create /mnt/@/.snapshots
#mkdir /mnt/@/.snapshots/1
#btrfs subvolume create /mnt/@/.snapshots/1/snapshot
##mkdir -p /mnt/@/boot/grub2/
##btrfs subvolume create /mnt/@/boot/grub2/i386-pc
##btrfs subvolume create /mnt/@/boot/grub2/x86_64-efi
#btrfs subvolume create /mnt/@/home
#btrfs subvolume create /mnt/@/opt
#btrfs subvoulme create /mnt/@/root
#btrfs subvolume create /mnt/@/srv
#btrfs subvolume create /mnt/@/tmp
#mkdir /mnt/@/usr/
#btrfs subvolume create /mnt/@/usr/local
#btrfs subvolume create /mnt/@/var

#read -p 'Press [Enter] key to continue...'

##chattr +C /mnt/@/var

#datetime=$(date +"%Y-%m-%d %T")
#infoxml=/mnt/@/.snapshots/1/info.xml
#echo '<?xml version="1.0"?>' > $infoxml
#echo '<snapshot>' >> $infoxml
#echo '  <type>single</type>' >> $infoxml
#echo '  <num>1</num>' >> $infoxml
#echo '  <date>'$datetime'</date>' >> $infoxml
#echo '  <description>first root filesystem</description>' >> $infoxml
#echo '</snapshot>' >> $infoxml

#read -p 'Press [Enter] key to continue...'

#btrfs subvolume set-default $(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /mnt

#read -p 'Press [Enter] key to continue...'

##unmount /mnt
##mount $devroot /mnt -o noatime,compress=zstd:1,subvol=@
#mount $devroot /target -o noatime,compress=zstd:1 

#read -p 'Press [Enter] key to continue...'

#mkdir -p /target/.snapshots
##mkdir -p /target/boot/grub2/i386-pc
##mkdir -p /target/boot/grub2/x86_64-efi
#mkdir -p /target/boot/efi
#mkdir -p /target/home
#mkdir -p /target/opt
#mkdir -p /target/root
#mkdir -p /target/srv
#mkdir -p /target/tmp
#mkdir -p /target/usr/local
#mkdir -p /target/var

#read -p 'Press [Enter] key to continue...'

#mount $devroot /target/.snapshots -o noatime,compress=zstd:1,subvol=@/.snapshots
##mount $devroot /target/boot/grub2/i386-pc    -o noatime,compress=zstd:1,subvol=@/boot/grub2/i386-pc
##mount $devroot /target/boot/grub2/x86_64-efi -o noatime,compress=zstd:1,subvol=@/boot/grub2/x86_64-efi
#mount $devroot /target/home       -o noatime,compress=zstd:1,subvol=@/home
#mount $devroot /target/opt        -o noatime,compress=zstd:1,subvol=@/opt
#mount $devroot /target/root       -o noatime,compress=zstd:1,subvol=@/root
#mount $devroot /target/srv        -o noatime,compress=zstd:1,subvol=@/srv
#mount $devroot /target/tmp        -o noatime,compress=zstd:1subvol=@/tmp
#mount $devroot /target/usr/local  -o noatime,compress=zstd:1,subvol=@/usr/local
#mount $devroot /target/var        -o compress=zstd:1,subvol=@/var,noatime
#mount $devboot /target/boot
#mount $devuefi /target/boot/efi

#read -p 'Press [Enter] key to continue...'

#mv /mnt/etc /target/
#mv mnt/media /target/

#read -p 'Press [Enter] key to continue...'

#fstab=/target/etc/fstab
#echo '# /etc/fstab: static file system information.' >> $fstab
#echo '#' >> $fstab
#echo '# Use 'blkid' to print the universally unique identifier for a' >> $fstab
#echo '# device; this may be used with UUID= as a more robust way to name devices' >> $fstab
#echo '# that works even if disks are added and removed. See fstab(5).' >> $fstab
#echo '#' >> $fstab
#echo '# systemd generates mount units based on this file, see systemd.mount(5).' >> $fstab
#echo '# Please run 'systemctl daemon-reload' after making changes here.' >> $fstab
#echo '#' >> $fstab
#echo '# <file system> <mount point>   <type>  <options>       <dump>  <pass>' >> $fstab
#echo $devroot' /             btrfs   noatime,compress=zstd:1  0       0' >> $fstab
#echo $devroot' /.snapshots   btrfs   noatime,compress=zstd:1,subvol=@/.snapshots  0       0' >> $fstab
#echo $devroot' /home         btrfs   noatime,compress=zstd:1,subvol=@/home  0       0' >> $fstab
#echo $devroot' /opt          btrfs   noatime,compress=zstd:1,subvol=@/opt   0       0' >> $fstab
#echo $devroot' /root         btrfs   noatime,compress=zstd:1,subvol=@/root  0       0' >> $fstab
#echo $devroot' /srv          btrfs   noatime,compress=zstd:1,subvol=@/srv   0       0' >> $fstab
#echo $devroot' /tmp          btrfs   noatime,compress=zstd:1,subvol=@/tmp   0       0' >> $fstab
#echo $devroot' /usr/local    btrfs   noatime,compress=zstd:1,subvol=@/usr/local  0       0' >> $fstab
#echo $devroot' /var          btrfs   noatime,compress=zstd:1,subvol=@/var  0       0' >> $fstab
#echo '' >> $fstab
#echo '# /boot was on '$devboot' during installation' >> $fstab
#echo 'UUID='$idboot' /boot           ext4    noatime         0       2' >> $fstab
#echo '' >> $fstab
#echo '# /boot/efi was on '$devuefi' during installation' >> $fstab
#echo 'UUID='$iduefi'  /boot/efi       vfat    umask=0077      0       1' >> $fstab

#read -p 'Press [Enter] key to continue...'

#unmount /mnt
