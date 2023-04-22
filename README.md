# Fedora 38 auf dem Lenovo Yoga 7 16IAH7

## Hardware Informationen

|   |   |
|---|---|
Hardwaremodell      |  Lenovo Yoga 7 16IAH7 82UF  
Firmware-Version    | J1CN37WW  
Speicher            | 16,0 GiB
Prozessor           | 12th Gen Intel® Core™ i7-12700H × 20
Grafik              |  Intel® Arc™ A370M Graphics (DG2) / Intel® Graphics (ADL GT2)
Festlattenkapazität | 1,0 TB

---

## Pre-Installation

---

## Initiale Installation

---

## Post Instllation

### Fractional Scaling aktivieren

https://www.omglinux.com/how-to-enable-fractional-scaling-fedora/

### Hostnamen anpassen
### DNF konfigurieren
### System aktualisieren
### RPM Fusion aktivieren
### Flathub Repository aktivieren

https://itsfoss.com/things-to-do-after-installing-fedora/  


`sudo hostnamectl set-hostname "esmeralda"`  

```
# Fractional Scaling aktivieren
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
# Fractional Scaling deaktiviern
#gsettings set org.gnome.mutter experimental-features "[]"
```

`sudo dnf update --refresh`  

`sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm`  

```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remote-delete fedora
```
<!---
### Intel ARC A380M GPU aktivieren

```
sudo lspci -k | grep -EA3 'VGA|3D|Display'
sudo lspci -nn | grep -EA3 'VGA|3D|Display'
#sudo grubby --update-kernel=ALL --args="i915.force_probe=<pci ID>"
sudo grubby --update-kernel=ALL --args="i915.force_probe=5693"
#sudo grubby --update-kernel=ALL --remove-args="i915.force_probe=<pci ID>"
cat /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

https://www.reddit.com/r/Fedora/comments/10je7as/how_to_get_intel_arc_working_on_fedora_a770_a750/
https://forums.fedoraforum.org/showthread.php?329171-Intel-Arc-GPU-thread  
https://wiki.archlinux.org/title/intel_graphics  
https://www.reddit.com/r/Fedora/comments/zg0v2v/fedora_37_not_loading_i915arc_770m_gpu_on_boot/  
-->

### Realtek ALC3306 konfigurieren

https://discussion.fedoraproject.org/t/problem-with-sound-on-new-lenovo-laptops/72456/6

```
sudo nano  /etc/modprobe.d/snd.conf
```
Folgende Optionen aktivieren
```
options snd_intel_dspcfg dsp_driver=1
options snd_hda_intel model=alc287-yoga9-bass-spk-pin
```

<!---
### Kernel Fehler "xorg-x11-drv-intel" beheben

`journalctl -b -k | grep "split lock"`

```
sudo grubby --update-kernel=ALL --args="split_lock_detect=off"
cat /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
https://forums.fedoraforum.org/showthread.php?330146-kernel-core-unexpected-system-error&p=1868001
-->

---

## Software

### Multimedia Pakete

```
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel

sudo dnf install lame\* --exclude=lame-devel

sudo dnf group upgrade --with-optional Multimedia
```

### Diverse Pakete

```
sudo dnf install -y neofetch
```

### 1Password installieren

https://support.1password.com/install-linux/#centos-fedora-or-red-hat-enterprise-linux

### Visual Studio Code

```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf check-update

sudo dnf install code
```
