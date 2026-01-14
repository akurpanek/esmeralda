#!/bin/bash

# Script to configure Btrfs subvolumes and mount points for a Debian system.
# Based on: https://raw.githubusercontent.com/akurpanek/esmeralda/main/Debian/partition.sh
# Reference: https://blog.cscholz.io/debian-einsatz-snapper/

# --- Get device and UUID information ---
# Extract device paths for root, boot, efi, and cdrom from /proc/mounts
devroot=$(awk '$2 == "/target" {print $1}' /proc/mounts)
devboot=$(awk '$2 == "/target/boot" {print $1}' /proc/mounts)
devuefi=$(awk '$2 == "/target/boot/efi" {print $1}' /proc/mounts)
devdisk=$(awk '$2 == "/cdrom" {print $1}' /proc/mounts)

# Extract UUIDs for root, boot, and efi partitions
idroot=$(blkid -o value -s UUID "$devroot")
idboot=$(blkid -o value -s UUID "$devboot")
iduefi=$(blkid -o value -s UUID "$devuefi")

# --- Unmount existing mounts ---
# Unmount all relevant directories to prepare for reconfiguration
for i in target/boot/efi target/boot target/media/cdrom target/media/cdrom0 target; do
    umount "/$i" 2>/dev/null || true
done

# --- Configure Btrfs subvolumes ---
# Mount root with subvolid=5 to access the top-level subvolume
mount "$devroot" /target -o subvolid=5

# Rename @rootfs to @ for consistency with Btrfs best practices
mv /target/@rootfs /target/@

# Create necessary subvolumes and directories
btrfs subvolume create /target/@/.snapshots
for i in usr .snapshots/1; do
    mkdir -p "/target/@/$i"
done

# Create subvolumes for system directories
for i in .snapshots/1/snapshot home opt root srv tmp usr/local var; do
    btrfs subvolume create "/target/@/$i"
done

# Move existing directories to the first snapshot
for i in boot etc media; do
    mv "/target/@/$i" /target/@/.snapshots/1/snapshot/
done

# --- Create snapshot metadata ---
# Generate XML info for the first snapshot
datetime=$(date +"%Y-%m-%d %T")
infoxml=/target/@/.snapshots/1/info.xml
cat >"$infoxml" <<EOL
<?xml version="1.0"?>
<snapshot>
    <type>single</type>
    <num>1</num>
    <date>${datetime}</date>
    <description>first root filesystem</description>
</snapshot>
EOL

# --- Set default subvolume ---
# Set the first snapshot as the default subvolume
btrfs subvolume set-default \
    $(btrfs subvolume list /target | awk '$9 == "@/.snapshots/1/snapshot" {print $2}') \
    /target

# --- Remount with compression ---
# Unmount and remount root with compression and noatime
umount /target
mount "$devroot" /target -o noatime,compress=zstd:1

# Create mount points for subvolumes
for i in .snapshots home opt root srv tmp usr/local var; do
    mkdir -p "/target/$i"
done

# Mount subvolumes with compression and noatime
for i in .snapshots home opt root srv tmp usr/local var; do
    mount "$devroot" "/target/$i" -o noatime,compress=zstd:1,subvol="@/$i"
done

# --- Mount boot, efi, and cdrom ---
mount "$devboot" /target/boot
mount "$devuefi" /target/boot/efi
mount "$devdisk" /target/media/cdrom0

# --- Generate fstab ---
# Create a new fstab with Btrfs subvolumes and UUIDs
fstab=/target/etc/fstab
cat >"$fstab" <<EOL
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

# --- Ensure cdrom is mounted ---
# Retry mounting cdrom if it unmounts unexpectedly
while [ "$(awk '$2 == "/target/media/cdrom0" {print $2}' /proc/mounts)" = "/target/media/cdrom0" ]; do
    sleep 1s
    if [ "$(awk '$2 == "/target/media/cdrom0" {print $2}' /proc/mounts)" != "/target/media/cdrom0" ]; then
        echo "Mounting..."
        mount "$devdisk" /target/media/cdrom0
    fi
done
