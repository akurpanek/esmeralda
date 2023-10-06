# Debian 12 GNOME

## OS-Installation

### Pre-Installation

### Installation

### Post-Installation

#### Hostname konfigurieren

```shell
sudo hostnamectl set-hostname "esmeralda"
```

#### Hardware konfigurieren

```shell
# Apply tinny and quiet sound fix for bass speakers and internal microphone on Lenovo 7i
grep -iq '^options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin' /etc/modprobe.d/snd.conf || \
    echo "options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin" | \
    sudo tee -a /etc/modprobe.d/snd.conf
```

#### BTRFS Snapshots einrichten

```shell
# Copy-on-Write-Verfahren deaktivieren
sudo chattr -fR +C /var
```
```shell
# Snapper einrichten
sudo apt install -y snapper-gui git inotify-tools
sudo systemctl disable snapper-boot.timer
```
```shell
# Snapper für root-Volume konfigurieren
sudo umount /.snapshots
if [ -d "/.snapshots" ]; then sudo mv /.snapshots /.snapshots.snapper_config; fi
sudo snapper -c root create-config /
if [ -d "/.snapshots" ]; then sudo rmdir /.snapshots; fi
if [ -d "/.snapshots.snapper_config" ]; then sudo mv /.snapshots.snapper_config /.snapshots; fi
sudo mount /.snapshots

sudo snapper -c root set-config 'TIMELINE_CREATE=no'
sudo snapper -c root set-config 'ALLOW_GROUPS=sudo'
sudo snapper -c root set-config 'SYNC_ACL=yes'

sudo snapper -c root set-config 'TIMELINE_MIN_AGE="1800"'
sudo snapper -c root set-config 'TIMELINE_LIMIT_HOURLY="5"'
sudo snapper -c root set-config 'TIMELINE_LIMIT_DAILY="7"'
sudo snapper -c root set-config 'TIMELINE_LIMIT_WEEKLY="0"'
sudo snapper -c root set-config 'TIMELINE_LIMIT_MONTHLY="0"'
sudo snapper -c root set-config 'TIMELINE_LIMIT_YEARLY="0"'
```
```shell
# Snapper für home-Volume konfigurieren
sudo snapper -c home create-config /home

sudo snapper -c home set-config 'TIMELINE_CREATE=no'
sudo snapper -c home set-config 'ALLOW_GROUPS=sudo'
sudo snapper -c home set-config 'SYNC_ACL=yes'

sudo snapper -c home set-config 'TIMELINE_MIN_AGE="1800"'
sudo snapper -c home set-config 'TIMELINE_LIMIT_HOURLY="5"'
sudo snapper -c home set-config 'TIMELINE_LIMIT_DAILY="7"'
sudo snapper -c home set-config 'TIMELINE_LIMIT_WEEKLY="0"'
sudo snapper -c home set-config 'TIMELINE_LIMIT_MONTHLY="0"'
sudo snapper -c home set-config 'TIMELINE_LIMIT_YEARLY="0"'
```
```shell
# GRUB-BTRFS einrichten
sudo apt-get install -y build-essential
cd ~
sudo git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
sudo systemctl enable --now grub-btrfsd
sudo systemctl status grub-btrfsd
cd ~
sudo rm -rf grub-btrfs
```

#### CDROM als Installationsqelle deaktiveren
 
```shell
sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
```

#### System aktualisieren

```shell
# Cache aktualisieren, Updates installieren und verwaiste Pakete entfernen
sudo apt update -y && \
    sudo apt upgrade -y && \
    sudo apt autoremove  --purge -y
```

#### Basissoftware installieren

```shell
sudo apt install -y build-essential lshw neofetch vim needrestart wget gpg git apt-transport-https
```

#### Kernel aus Backports aktualisieren

Quellen:

- <https://wiki.debian.org/Firmware#Debian_12_.28bookworm.29_and_later>

```shell
# Kernel aus Backports installieren
sudo apt install -y -f -t bookworm-backports linux-image-amd64 firmware-linux #linux-headers-amd64

# Firmwware-Dateien von git.kernel.org herunterladen
mkdir ~/firmware
wget -P ~/firmware/ -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915/
sudo mv ~/firmware/*.bin /lib/firmware/i915/

# Initramfs aktualisieren
sudo update-initramfs -c -k all
```

#### Plymouth Theme einrichten

Quellen:

- <https://wiki.debian.org/plymouth>
- <https://wiki.archlinux.org/title/plymouth>

```shell
# Plymouth installieren
sudo apt install -y plymouth-themes

# Plymouth Konfigurtion anpassen
sudo sed -i 's/^#\[Daemon\].*/[Daemon]/' /etc/plymouth/plymouthd.conf
if $(cat /etc/plymouth/plymouthd.conf | grep -iq '^DeviceScale')
then
    sudo sed -i 's/^DeviceScale.*/DeviceScale=2/' /etc/plymouth/plymouthd.conf
else
    echo "DeviceScale=2" | sudo tee -a /etc/plymouth/plymouthd.conf
fi

# Initramfs aktualisieren
sudo update-initramfs -c -k all

# Grub Konfiguration anpassen
grep -iq '^GRUB_CMDLINE_LINUX_DEFAULT.*splash' /etc/default/grub || \
    sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"$#\1 splash"#' /etc/default/grub
grep -iq '^GRUB_CMDLINE_LINUX_DEFAULT.*loglevel' /etc/default/grub || \
    sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"$#\1 loglevel=0"#' /etc/default/grub

# Grub aktualisieren
sudo update-grub
```

#### (Z)SWAP aktivieren

Quellen:

- <https://wiki.archlinux.org/title/zswap>
- <https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation>

```shell
sudo apt install -y zram-tools
sudo sed -i "s/^#PERCENT=.*/PERCENT=50/g" /etc/default/zramswap
sudo sed -i "s/^PERCENT=.*/PERCENT=50/g" /etc/default/zramswap
sudo systemctl restart zramswap.service
```

## GNOME Konfiguration

#### Fractional Scaling konfigurieren

Quellen:

- <https://wiki.archlinux.org/title/HiDPI#Wayland>
 
```shell
# Fractional Scaling Wayland aktivieren
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```
```shell
# Fractional Scaling X11 aktivieren
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```
```shell
# Fractional Scaling deaktiviern
gsettings reset org.gnome.mutter experimental-features
```

#### Flatpak einrichten

Quellen:

- <https://docs.flatpak.org/en/latest/sandbox-permissions.html>
- <https://docs.flatpak.org/en/latest/sandbox-permissions-reference.html>
- <https://wiki.debian.org/Flatpak>

```shell
# Flatpkak und GNOME Software Plugin installieren
sudo apt install -y flatpak gnome-software-plugin-flatpak

# Flathub Repository hinzufügen
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# GNOME Software zurrücksetzen
killall gnome-software
rm -rf ~/.cache/gnome-software

# Flatseal installieren
sudo flatpak install -y flathub com.github.tchx84.Flatseal
```

#### GNOME Shell Extension installieren

Quellen:

- <https://extensions.gnome.org/>
- <https://unix.stackexchange.com/questions/617288/command-line-tool-to-install-gnome-shell-extensions>

#### GNOME Themes Qt und GTK

Quellen:

- <https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications>

```shell
sudo apt install -y adwaita-qt
```

## Software Installation

### Container- und Virtualisierung

#### KVM/QEMU und XLC installieren

**Quellen:**

- <https://wiki.debian.org/SystemVirtualization>
- <https://wiki.debian.org/KVM>
- <https://wiki.debian.org/LXC>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

```shell
# QEMU, KVM, LXC, libvirt, spice und GUI virt-manager installieren
sudo apt install -y qemu-system libvirt-daemon-system lxc virt-manager

# Nested Virtualization aktivieren
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1

# Nested Virtualization permanent aktivieren
grep -iq '^options kvm_intel nested=1' /etc/modprobe.d/kvm.conf || \
    echo "options kvm_intel nested=1" | \
    sudo tee -a /etc/modprobe.d/kvm.conf

# Aktuellen Benutzer zur Gruppe libvirt hnzufügen
sudo adduser $USERNAME libvirt
```

#### KVM/QEMU Guest Tools installieren

```shell
# Spice Client installieren und starten
if $(sudo dmesg | grep -iq 'Hypervisor detected.*KVM'); then
    sudo apt install spice-vdagent
    sudo systemctl enable spice-vdagentd.service
    sudo systemctl start spice-vdagentd.service
fi
```

### Datenverschlüsselung, Datensicherung und Replikation

#### PIKA Backup einrichten

```shell
# PIKA Backup installieren
sudo flatpak install -y flathub org.gnome.World.PikaBackup
```

#### Nextcloud Desktop einrichten

Quellen:

- <https://wiki.debian.org/Nextcloud#Nextcloud_desktop_clients>
- <https://nextcloud.com/de/install/>

```shell
# Nextcloud Desktop und Plugins installieren
sudo apt install -y nautilus-nextcloud
```

#### Cryptomator einrichten

Quellen:

- <https://cryptomator.org/downloads/linux/>

```shell
# Cryptomator installieren
sudo flatpak install -y flathub org.cryptomator.Cryptomator

# Cryptomator konfigurieren
flatpak override --user org.cryptomator.Cryptomator --reset
flatpak override --user org.cryptomator.Cryptomator --filesystem=host

# Cryptomator Alias setzen
alias signal='flatpak run org.cryptomator.Cryptomator'
grep -iq '^alias cryptomator=' ~/.bash_aliases || \
    echo "alias cryptomator='flatpak run org.cryptomator.Cryptomator'" | \
    tee -a ~/.bash_aliases
```


### Instant Messaging

#### Messenger einrichten

```shell
# WhatsApp Desktop installieren
sudo flatpak install -y flathub io.github.mimbrero.WhatsAppDesktop

# WhatsApp Desktop konfigurieren

# WhatsApp Desktop Alias setzen
alias whatsapp='flatpak run io.github.mimbrero.WhatsAppDesktop'
grep -iq '^alias whatsapp=' ~/.bash_aliases || \
    echo "alias whatsapp='flatpak run io.github.mimbrero.WhatsAppDesktop'" | \
    tee -a ~/.bash_aliases
```

```shell
# Signal Desktop installieren
sudo flatpak install -y flathub org.signal.Signal

# Signal Desktop konfigurieren
flatpak override --user org.signal.Signal --reset
flatpak override --user org.signal.Signal --filesystem=host
flatpak override --user org.signal.Signal --env=SIGNAL_USE_TRAY_ICON=1

# Signal Desktop Alias setzen
alias signal='flatpak run org.signal.Signal'
grep -iq '^alias signal=' ~/.bash_aliases || \
    echo "alias signal='flatpak run org.signal.Signal'" | \
    tee -a ~/.bash_aliases
```




