#!/bin/bash

#
# Version 5
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

for i in target/boot/efi target/boot target/media/cdrom target/media/cdrom0 target; do umount /$i; done

mount $devroot /target -o subvolid=5
mv /target/@rootfs /target/@

#btrfs subvolume create /target/@
btrfs subvolume create /target/@/.snapshots

#for i in boot/grub2 usr .snapshots/1; do mkdir -p /target/@/$i; done
for i in usr .snapshots/1; do mkdir -p /target/@/$i; done

#for i in .snapshots/1/snapshot home boot/grub2/i386-pc boot/grub2/x86_64-efi opt root srv tmp usr/local var; do btrfs subvolume create /target/@/$i; done
for i in .snapshots/1/snapshot home opt root srv tmp usr/local var; do btrfs subvolume create /target/@/$i; done


#chattr +C /target/@/var
for i in boot etc media; do mv /target/@/$i /target/@/.snapshots/1/snapshot/; done


datetime=$(date +"%Y-%m-%d %T")
infoxml=/target/@/.snapshots/1/info.xml

#echo '<?xml version="1.0"?>' > $infoxml
#echo '<snapshot>' >> $infoxml
#echo '  <type>single</type>' >> $infoxml
#echo '  <num>1</num>' >> $infoxml
#echo '  <date>'$datetime'</date>' >> $infoxml
#echo '  <description>first root filesystem</description>' >> $infoxml
#echo '</snapshot>' >> $infoxml

cat >$infoxml <<EOL
<?xml version="1.0"?>
<snapshot>
    <type>single</type>
    <num>1</num>
    <date>${datetime}</date>
    <description>first root filesystem</description>
    </snapshot>
EOL




#btrfs subvolume set-default $(btrfs subvolume list /target | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /target
btrfs subvolume set-default $(btrfs subvolume list /target | awk '$9 == "@/.snapshots/1/snapshot" {print $2}') /target

umount /target
mount $devroot /target -o noatime,compress=zstd:1 

#for i in .snapshots boot/grub2/i386-pc boot/grub2/x86_64-efi home opt root srv tmp usr/local var; do mkdir -p /target/$i; done
for i in .snapshots home opt root srv tmp usr/local var; do mkdir -p /target/$i; done

#for i in .snapshots boot/grub2/i386-pc boot/grub2/x86_64-efi home opt root srv tmp usr/local var; do mount $devroot /target/$i -o noatime,compress=zstd:1,subvol=@/$i; done
for i in .snapshots home opt root srv tmp usr/local var; do mount $devroot /target/$i -o noatime,compress=zstd:1,subvol=@/$i; done

mount $devboot /target/boot
mount $devuefi /target/boot/efi
mount $devdisk /target/media/cdrom0

fstab=/target/etc/fstab
#echo '# /etc/fstab: static file system information.' > $fstab
#echo '#' >> $fstab
#echo '# Use '"'"'blkid'"'"' to print the universally unique identifier for a' >> $fstab
#echo '# device; this may be used with UUID= as a more robust way to name devices' >> $fstab
#echo '# that works even if disks are added and removed. See fstab(5).' >> $fstab
#echo '#' >> $fstab
#echo '# systemd generates mount units based on this file, see systemd.mount(5).' >> $fstab
#echo '# Please run '"'"'systemctl daemon-reload'"'"' after making changes here.' >> $fstab
#echo '#' >> $fstab
#echo '# <file system> <mount point>   <type>  <options>       <dump>  <pass>' >> $fstab
#echo $devroot' /             btrfs   noatime,compress=zstd:1  0       0' >> $fstab
#echo '#'$devroot' /.snapshots   btrfs   noatime,compress=zstd:1,subvol=@/.snapshots  0       0' >> $fstab
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





cat >$fstab <<EOL
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# systemd generates mount units based on this file, see systemd.mount(5).
# Please run 'systemctl daemon-reload' after making changes here.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
${devroot} /             btrfs   noatime,compress=zstd:1  0       0
#${devroot} /.snapshots   btrfs   noatime,compress=zstd:1,subvol=@/.snapshots  0       0
${devroot} /home         btrfs   noatime,compress=zstd:1,subvol=@/home  0       0
${devroot} /opt          btrfs   noatime,compress=zstd:1,subvol=@/opt   0       0
${devroot} /root         btrfs   noatime,compress=zstd:1,subvol=@/root  0       0
${devroot} /srv          btrfs   noatime,compress=zstd:1,subvol=@/srv   0       0
${devroot} /tmp          btrfs   noatime,compress=zstd:1,subvol=@/tmp   0       0
${devroot} /usr/local    btrfs   noatime,compress=zstd:1,subvol=@/usr/local  0       0
${devroot} /var          btrfs   noatime,compress=zstd:1,subvol=@/var  0       0

# /boot was on ${devboot} during installation
UUID=${idboot} /boot           ext4    noatime         0       2

# /boot/efi was on ${devuefi} during installation
UUID=${iduefi}  /boot/efi       vfat    umask=0077      0       1
EOL







while [ "$(awk '$2 == "/media/cdrom" {print $2}' /proc/mounts)" = "/media/cdrom" ]; do
    sleep 1s
    while [ "$(awk '$2 == "/media/cdrom" {print $2}' /proc/mounts)" != "/media/cdrom" ]; do
        echo "Mounting..."
        mount $devdisk /target/media/cdrom0
    done
done
