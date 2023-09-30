# Debian 12 GNOME

## OS-Installation

### Pre-Installation

### Installation

### Post-Installation

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

#### Hostname konfigurieren

```shell
sudo hostnamectl set-hostname "esmeralda"
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

- <https://wiki.debian.org/Flatpak>

```shell
# Flatpkak und GNOME Software Plugin installieren
sudo apt install -y flatpak gnome-software-plugin-flatpak

# Flathub Repository hinzufügen
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# GNOME Software zurrücksetzen
killall gnome-software
rm -rf ~/.cache/gnome-software
```



## Software Installation

### Container- und Virtualisierung

#### KVM und XLC installieren

**Quellen:**

- <https://wiki.debian.org/SystemVirtualization>
- <https://wiki.debian.org/KVM>
- <https://wiki.debian.org/LXC>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

```shell
# QEMU, KVM, LXC, libvirt und GUI virt-manager installieren
sudo apt install -y qemu-system libvirt-daemon-system lxc virt-manager

# Nested Virtualization aktivieren
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Aktuellen Benutzer zur Gruppe libvirt hnzufügen
sudo adduser $USERNAME libvirt
```
### Datensicherung

#### PIKA Backup einrichten

```shell
# PIKA Backup installieren
sudo flatpak install -y flathub org.gnome.World.PikaBackup
```


### Instant Messaging

#### Messenger einrichten

```shell
# WhatsApp Desktop installieren
sudo flatpak install -y flathub io.github.mimbrero.WhatsAppDesktop
```

```shell
# Signal Desktop installieren
sudo flatpak install -y flathub org.signal.Signal
```

