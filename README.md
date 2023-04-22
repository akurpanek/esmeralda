# Fedora 38 auf dem Lenovo Yoga 7 16IAH7

## Hinweise

Quellen:

- <https://www.markdownguide.org/basic-syntax/>

---

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

Quellen:

- <https://itsfoss.com/things-to-do-after-installing-fedora/>  
- <https://github.com/devangshekhawat/Fedora-38-Post-Install-Guide>

### Hostnamen anpassen

```shell
sudo hostnamectl set-hostname "esmeralda"
```

### Fractional Scaling aktivieren

```shell
# Fractional Scaling aktivieren
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

```shell
# Fractional Scaling deaktiviern
#gsettings set org.gnome.mutter experimental-features "[]"
```

Quellen:

- <https://www.omglinux.com/how-to-enable-fractional-scaling-fedora/>  

### DNF konfigurieren

### RPM Fusion aktivieren

```shell
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                 https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

```shell
sudo dnf groupupdate core
```

### System aktualisieren

```shell
`sudo dnf update --refresh`  
```

### Flathub Repository aktivieren

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remote-delete fedora
```
<!---

### Intel ARC A380M GPU aktivieren

```shell
sudo lspci -k | grep -EA3 'VGA|3D|Display'
sudo lspci -nn | grep -EA3 'VGA|3D|Display'
#sudo grubby --update-kernel=ALL --args="i915.force_probe=<pci ID>"
sudo grubby --update-kernel=ALL --args="i915.force_probe=5693"
#sudo grubby --update-kernel=ALL --remove-args="i915.force_probe=<pci ID>"
cat /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Quellen:

- <https://www.reddit.com/r/Fedora/comments/10je7as/how_to_get_intel_arc_working_on_fedora_a770_a750/>
- <https://forums.fedoraforum.org/showthread.php?329171-Intel-Arc-GPU-thread>
- <https://wiki.archlinux.org/title/intel_graphics>
- <https://www.reddit.com/r/Fedora/comments/zg0v2v/fedora_37_not_loading_i915arc_770m_gpu_on_boot/>

-->

### H/W Video-Beschleunigung

```shell
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
#sudo dnf install --allowerasing ffmpeg ffmpeg-libs libva libva-utils
```

```shell
sudo dnf install intel-media-driver
```

### Akkulaufzeit verbessern

```shell
sudo dnf install tlp tlp-rdw
sudo systemctl mask power-profiles-daemon
```
```shell
sudo dnf install powertop
sudo powertop --auto-tune
```

### Realtek ALC3306 konfigurieren

```shell
sudo nano  /etc/modprobe.d/snd.conf
```

Folgende Optionen aktivieren

```shell
options snd_intel_dspcfg dsp_driver=1
options snd_hda_intel model=alc287-yoga9-bass-spk-pin
```

Quellen:

- <https://discussion.fedoraproject.org/t/problem-with-sound-on-new-lenovo-laptops/72456/6>

<!---

### Kernel Fehler "xorg-x11-drv-intel" beheben

```shell
journalctl -b -k | grep "split lock"
```

```shell
sudo grubby --update-kernel=ALL --args="split_lock_detect=off"
cat /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Quellen:

- <https://forums.fedoraforum.org/showthread.php?330146-kernel-core-unexpected-system-error&p=1868001>

-->

---

## Software

### Multimedia Pakete installieren

```shell
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} \
                 gstreamer1-plugin-openh264 gstreamer1-libav \
                 --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
```

### Nützliche Pakete installieren

```shell
sudo dnf install -y neofetch
```

### 1Password installieren

Quellen:

- <https://support.1password.com/install-linux/#centos-fedora-or-red-hat-enterprise-linux>

### Visual Studio Code

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code
```

```shell
xdg-mime default code.desktop text/plain
```

```shell
code --install-extension MS-CEINTL.vscode-language-pack-de
```

Quellen:

- <https://code.visualstudio.com/docs/editor/extension-marketplace>
