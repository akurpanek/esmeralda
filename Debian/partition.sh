#!/bin/bash

#
# Version 4
#

# https://raw.githubusercontent.com/akurpanek/esmeralda/main/Debian/partition.sh
# https://blog.cscholz.io/debian-einsatz-snapper/

devroot=$(awk '$2 == "/target" {print $1}' /proc/mounts)
devboot=$(awk '$2 == "/target/boot" {print $1}' /proc/mounts)
devuefi=$(awk '$2 == "/target/boot/efi" {print $1}' /proc/mounts)
devdisk=$(awk '$2 == "/cdrom" {print $1}' /proc/mounts)

idroot=$(blkid -o value -s UUID $devroot)
idboot=$(blkid -o value -s UUID $devboot)
iduefi=$(blkid -o value -s UUID $devuefi)

#umount /target/boot/efi
#umount /target/boot
#umount /target
for i in target/boot/efi target/boot target/media/cdrom target/media/cdrom0 target; do umount /$i; done

mount $devroot /target -o subvolid=5
mv /target/@rootfs /target/@

#btrfs subvolume create /target/@
btrfs subvolume create /target/@/.snapshots

##mkdir -p /mnt/@/boot/grub2/
#mkdir /target/@/usr/
#mkdir /target/@/.snapshots/1
for i in usr .snapshots/1; do mkdir -p /target/@/$i; done

#btrfs subvolume create /target/@/.snapshots/1/snapshot
##btrfs subvolume create /target/@/boot/grub2/i386-pc
##btrfs subvolume create /target/@/boot/grub2/x86_64-efi
#btrfs subvolume create /target/@/home
#btrfs subvolume create /target/@/opt
#btrfs subvolume create /target/@/root
#btrfs subvolume create /target/@/srv
#btrfs subvolume create /target/@/tmp
#btrfs subvolume create /target/@/usr/local
#btrfs subvolume create /target/@/var
for i in .snapshots/1/snapshot home opt root srv tmp usr/local var; do btrfs subvolume create /target/@/$i; done


#chattr +C /target/@/var
#mv /target/@/boot /target/@/.snapshots/1/snapshot/
#mv /target/@/etc /target/@/.snapshots/1/snapshot/
#mv /target/@/media /target/@/.snapshots/1/snapshot/
for i in boot etc media; do mv /target/@/$i /target/@/.snapshots/1/snapshot/; done


datetime=$(date +"%Y-%m-%d %T")
infoxml=/target/@/.snapshots/1/info.xml
echo '<?xml version="1.0"?>' > $infoxml
echo '<snapshot>' >> $infoxml
echo '  <type>single</type>' >> $infoxml
echo '  <num>1</num>' >> $infoxml
echo '  <date>'$datetime'</date>' >> $infoxml
echo '  <description>first root filesystem</description>' >> $infoxml
echo '</snapshot>' >> $infoxml

#btrfs subvolume set-default $(btrfs subvolume list /target | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /target
btrfs subvolume set-default $(btrfs subvolume list /target | awk '$9 == "@/.snapshots/1/snapshot" {print $2}') /target

umount /target
mount $devroot /target -o noatime,compress=zstd:1 

#mkdir -p /target/.snapshots
##mkdir -p /target/boot/grub2/i386-pc
##mkdir -p /target/boot/grub2/x86_64-efi
##mkdir -p /target/boot/efi
#mkdir -p /target/home
#mkdir -p /target/opt
#mkdir -p /target/root
#mkdir -p /target/srv
#mkdir -p /target/tmp
#mkdir -p /target/usr/local
#mkdir -p /target/var
for i in .snapshots home opt root srv tmp usr/local var; do mkdir -p /target/$i; done

#mount $devroot /target/.snapshots -o noatime,compress=zstd:1,subvol=@/.snapshots
##mount $devroot /target/boot/grub2/i386-pc    -o noatime,compress=zstd:1,subvol=@/boot/grub2/i386-pc
##mount $devroot /target/boot/grub2/x86_64-efi -o noatime,compress=zstd:1,subvol=@/boot/grub2/x86_64-efi
#mount $devroot /target/home       -o noatime,compress=zstd:1,subvol=@/home
#mount $devroot /target/opt        -o noatime,compress=zstd:1,subvol=@/opt
#mount $devroot /target/root       -o noatime,compress=zstd:1,subvol=@/root
#mount $devroot /target/srv        -o noatime,compress=zstd:1,subvol=@/srv
#mount $devroot /target/tmp        -o noatime,compress=zstd:1,subvol=@/tmp
#mount $devroot /target/usr/local  -o noatime,compress=zstd:1,subvol=@/usr/local
#mount $devroot /target/var        -o noatime,compress=zstd:1,subvol=@/var
#mount $devboot /target/boot
#mount $devuefi /target/boot/efi
#mount $devdisk /target/media/cdrom0
for i in .snapshots home opt root srv tmp usr/local var; do mount $devroot /target/$i -o noatime,compress=zstd:1,subvol=@/$i; done
mount $devboot /target/boot
mount $devuefi /target/boot/efi
mount $devdisk /target/media/cdrom0

fstab=/target/etc/fstab
echo '# /etc/fstab: static file system information.' > $fstab
echo '#' >> $fstab
echo '# Use '"'"'blkid'"'"' to print the universally unique identifier for a' >> $fstab
echo '# device; this may be used with UUID= as a more robust way to name devices' >> $fstab
echo '# that works even if disks are added and removed. See fstab(5).' >> $fstab
echo '#' >> $fstab
echo '# systemd generates mount units based on this file, see systemd.mount(5).' >> $fstab
echo '# Please run '"'"'systemctl daemon-reload'"'"' after making changes here.' >> $fstab
echo '#' >> $fstab
echo '# <file system> <mount point>   <type>  <options>       <dump>  <pass>' >> $fstab
echo $devroot' /             btrfs   noatime,compress=zstd:1  0       0' >> $fstab
echo '#'$devroot' /.snapshots   btrfs   noatime,compress=zstd:1,subvol=@/.snapshots  0       0' >> $fstab
echo $devroot' /home         btrfs   noatime,compress=zstd:1,subvol=@/home  0       0' >> $fstab
echo $devroot' /opt          btrfs   noatime,compress=zstd:1,subvol=@/opt   0       0' >> $fstab
echo $devroot' /root         btrfs   noatime,compress=zstd:1,subvol=@/root  0       0' >> $fstab
echo $devroot' /srv          btrfs   noatime,compress=zstd:1,subvol=@/srv   0       0' >> $fstab
echo $devroot' /tmp          btrfs   noatime,compress=zstd:1,subvol=@/tmp   0       0' >> $fstab
echo $devroot' /usr/local    btrfs   noatime,compress=zstd:1,subvol=@/usr/local  0       0' >> $fstab
echo $devroot' /var          btrfs   noatime,compress=zstd:1,subvol=@/var  0       0' >> $fstab
echo '' >> $fstab
echo '# /boot was on '$devboot' during installation' >> $fstab
echo 'UUID='$idboot' /boot           ext4    noatime         0       2' >> $fstab
echo '' >> $fstab
echo '# /boot/efi was on '$devuefi' during installation' >> $fstab
echo 'UUID='$iduefi'  /boot/efi       vfat    umask=0077      0       1' >> $fstab

