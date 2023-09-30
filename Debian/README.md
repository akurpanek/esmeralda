# Debian 12 GNOME

## Installation

### Pre-Installation

### OS-Installation

### Post-Installation

##### CDROM als Installationsqelle deaktiveren

```shell
sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
```
##### Hostnamen anpassen

```shell
sudo hostnamectl set-hostname "esmeralda"
```

##### Fractional Scaling konfigurieren

```shell
# Fractional Scaling aktivieren
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```
```shell
# Fractional Scaling deaktiviern
gsettings set org.gnome.mutter experimental-features "[]"
```


# Base Installation

## KVM Virtualization

**Quellen:**

- <https://wiki.debian.org/KVM>
- <https://wiki.debian.org/LXC>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

**Installation und Setup:**

```shell
# QEMU, KVM, LXC, libvirt und GUI virt-manager installieren
sudo apt install -y qemu-system libvirt-daemon-system lxc virt-manager

# Nested Virtualization aktivieren
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Aktuellem Benutzer zur Gruppe libvirt hnzufügen und
# das Verwalten von VMs erlauben 
sudo adduser $USERNAME libvirt
```



