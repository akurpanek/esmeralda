
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

chattr +C /mnt/@/var


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

mkdir -p /target/boot/efi
mkdir -p /target/home
mkdir -p /target/opt
mkdir -p /target/root
mkdir -p /target/srv
mkdir -p /target/tmp
mkdir -p /target/usr/local
mkdir -p /target/var

