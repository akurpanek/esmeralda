# Fedora 38 auf dem Lenovo Yoga 7 16IAH7

## Hinweise

Quellen:

- <https://www.markdownguide.org/basic-syntax/>
- <https://www.heise.de/ratgeber/Wie-Sie-Debian-und-Ubuntu-verschluesselt-neben-Windows-installieren-7207059.html>

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
sudo dnf update --refresh
```

### Flathub Repository aktivieren

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remote-modify fedora --disable
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
#sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo dnf install --allowerasing ffmpeg ffmpeg-libs libva libva-utils
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

### Intel Alder Lake PCH-P High Definition Audio konfigurieren

Folgende Modulparameter durch erstellen der Datei `/etc/modprobe.d/snd.conf`konfigurieren:

```shell
options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin
```

Quellen:

- <https://askubuntu.com/questions/1243369/sound-card-not-detected-ubuntu-20-04-sof-audio-pci>
- <https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture/Troubleshooting#Intel_Cannon_Lake_PCH_cAVS>


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

### Englische Benutzerordner xdg-user-dir einrichten

```shell
# Benutzerordner umbenennen
if [ ! -d ~/Pictures ]; then mv ~/Bilder ~/Pictures; fi
if [ ! -d ~/Music ]; then mv ~/Musik ~/Music; fi
if [ ! -d ~/Videos ]; then mv ~/Videos ~/Videos; fi
if [ ! -d ~/Documents ]; then mv ~/Dokumente ~/Documents; fi
if [ ! -d ~/Public ]; then mv ~/Öffentlich ~/Public; fi
if [ ! -d ~/Desktop ]; then mv ~/Schreibtisch ~/Desktop; fi
if [ ! -d ~/Templates ]; then mv ~/Vorlagen ~/Templates; fi
```

```shell
# Config-Datei aktualsiieren
echo 'en_US' > ~/.config/user-dirs.locale
```

```shell
# Benutzerordner aktualisieren
LC_ALL=en_US xdg-user-dirs-update --force
LC_ALL=en_US xdg-user-dirs-gtk-update --force
```

Quellen:

- <https://wiki.archlinux.org/title/XDG_user_directories>

## Software

### Multimedia Pakete installieren

```shell
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} \
                 gstreamer1-plugin-openh264 gstreamer1-libav \
                 --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
```
Quellen:

- <https://rpmfusion.org/Howto/Multimedia?highlight=%28%5CbCategoryHowto%5Cb%29>

### Nützliche Pakete

```shell
sudo dnf install -y neofetch \
                    inxi \
                    backintime-qt \
                    vim \

```

### Nextcloud Desktop Client

```shell
sudo dnf install nextcloud-client-nautilus
```

```shell
# lokale Benutzerordner in Nextcloud Benutzerordner verlinken
if [ -d ~/Pictures ]; then if rmdir ~/Pictures; then ln -s ~/Nextcloud/Pictures ~/Pictures; fi; fi
if [ -d ~/Music ]; then if rmdir ~/Music; then ln -s ~/Nextcloud/Music ~/Music; fi; fi
if [ -d ~/Videos ]; then if rmdir ~/Videos; then ln -s ~/Nextcloud/Videos ~/Videos; fi; fi
if [ -d ~/Documents ]; then if rmdir ~/Documents; then ln -s ~/Nextcloud/Documents ~/Documents; fi; fi
if [ -d ~/Public ]; then if rmdir ~/Public; then ln -s ~/Nextcloud/Public ~/Public; fi; fi
if [ -d ~/Desktop ]; then if rmdir ~/Desktop; then ln -s ~/Nextcloud/Desktop ~/Desktop; fi; fi
if [ -d ~/Templates ]; then if rmdir ~/Templates; then ln -s ~/Nextcloud/Templates ~/Templates; fi; fi
```

### Tor Browser

```shell
sudo dnf install torbrowser-launcher
torbrowser-launcher
```

### 1Password

Quellen:

- <https://support.1password.com/install-linux/#centos-fedora-or-red-hat-enterprise-linux>

### Visual Studio Code

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
```

```shell
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

### AnyDesk Remote-Desktop

```shell
sudo rpm --import https://keys.anydesk.com/repos/RPM-GPG-KEY
sudo sh -c 'echo -e "[anydesk]\nname=AnyDesk Fedora - stable\nbaseurl=http://rpm.anydesk.com/fedora/\$basearch/\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY" > /etc/yum.repos.d/AnyDesk-Fedora.repo'
```

```shell
sudo dnf check-update
#sudo dnf install anydesk
```
```shell
sudo dnf install https://download.anydesk.com/linux/anydesk-6.2.1-1.el8.x86_64.rpm
```


Quellen:

- <https://forums.fedoraforum.org/showthread.php?328899-anydesk-6-2-on-Fedora-(missing-libgtkglext-x11-1_0-0)&p=1867513#post1867513>

### Zoom Desktop Client für Linux

```shell
#sudo rpm --import https://zoom.us/linux/download/pubkey?version=5-12-6
#sudo dnf install https://zoom.us/client/5.14.5.2430/zoom_x86_64.rpm
```

```shell
flatpak install flathub us.zoom.Zoom
```

Quellen:

- <https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux>

### Microsoft Edge Browser

Quellen:

- <https://learn.microsoft.com/de-de/windows-server/administration/linux-package-repository-for-microsoft-software>

### Logitech Receiver 

```shell
sudo dnf install solaar solaar-udev
```

### Podman

```shell
sudo dnf -y install podman
```
