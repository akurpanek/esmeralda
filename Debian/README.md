# Debian 12 GNOME

## OS-Installation

### Pre-Installation

### Installation

### Post-Installation

###### CDROM als Installationsqelle deaktiveren

```shell
sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
```
###### Hostnamen anpassen

```shell
sudo hostnamectl set-hostname "esmeralda"
```

## GNOME Konfiguration

###### Fractional Scaling konfigurieren

Quellen:

- <https://wiki.archlinux.org/title/HiDPI#Wayland>

```shell
# Fractional Scaling aktivieren
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer','x11-randr-fractional-scaling']"
```
```shell
# Fractional Scaling deaktiviern
gsettings set org.gnome.mutter experimental-features "[]"
gsettings reset org.gnome.mutter experimental-features
```


Quellen:

- <https://wiki.debian.org/Flatpak>

## Software Installation

### Container- und Virtualisierung

**Quellen:**

- <https://wiki.debian.org/KVM>
- <https://wiki.debian.org/LXC>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

###### QEMU, KVM, LXC, libvirt und GUI virt-manager installieren
```shell
sudo apt install -y qemu-system libvirt-daemon-system lxc virt-manager
```

###### Nested Virtualization aktivieren
```shell
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf
```

###### Aktuellen Benutzer zur Gruppe libvirt hnzufügen
```shell
sudo adduser $USERNAME libvirt
```



