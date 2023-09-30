# Debian Installation

## Post-Installation

```shell
# CDROM als Installationsqelle in der 'sources.list' deaktiveren
sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
```

# Application Installation

## KVM Virtualization

**Quellen:**

- <https://wiki.debian.org/KVM#Installation>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

**Installation und Setup:**

```shell
# QEMU, KVM, QEUMU and libvirt installieren
sudo apt install -y qemu-system libvirt-daemon-system

# Nested Virtualization aktivieren
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Aktuellem Benutzer zur Gruppe libvirt hnzufügen und
# das Verwalten von VMs erlauben 
sudo adduser $USERNAME libvirt
```



