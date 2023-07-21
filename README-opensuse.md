# Opensuse Leap 15.5 auf dem Lenovo Yoga 7 16IAH7

## Hinweise

Quellen:

- <https://www.markdownguide.org/basic-syntax/>
- <https://www.heise.de/ratgeber/Wie-Sie-Debian-und-Ubuntu-verschluesselt-neben-Windows-installieren-7207059.html>

---

## Hardware Informationen

|   |   |
|---|---|
Hardwaremodell      | Lenovo Yoga 7 16IAH7 82UF  
Firmware-Version    | J1CN37WW  
Speicher            | 16,0 GiB
Prozessor           | 12th Gen Intel® Core™ i7-12700H × 20
Grafik              | Intel® Arc™ A370M Graphics (DG2) / Intel® Graphics (ADL GT2)
Festlattenkapazität | 1,0 TB

---

## Pre-Installation

---

## Initiale Installation

---

## Post Instllation

Quellen:

- <https://averagelinuxuser.com/after-installing-opensuse/>
- <https://itsfoss.com/things-to-do-after-installing-opensuse/>
- <https://de.opensuse.org/Paket_Repositorys>

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

### System aktualisieren

```shell
sudo zypper ref && sudo zypper up
```

### Snapshot erstellen

```shell
sudo snapper create --description "Vor den Änderungen nach der Installation" --print-number
```
```shell
> 3
```

### Intel Alder Lake PCH-P High Definition Audio konfigurieren

Folgende Modulparameter durch erstellen der Datei `/etc/modprobe.d/alsa-base.conf`konfigurieren:

```shell
options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin
```

Quellen:

- <https://askubuntu.com/questions/1243369/sound-card-not-detected-ubuntu-20-04-sof-audio-pci>
- <https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture/Troubleshooting#Intel_Cannon_Lake_PCH_cAVS>

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

### Packman Repository einbinden

```shell
sudo zypper ar -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_$releasever/' packman
sudo zypper dup --from packman --allow-vendor-change
```

### Nützliche Pakete

```shell
sudo zypper install neofetch \
                    backintime-qt backintime-lang\
                    vim \

```

### Nextcloud Desktop

```shell
#zypper addrepo https://download.opensuse.org/repositories/network/15.5/network.repo
#zypper refresh
zypper install nextcloud-desktop
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

Quellen:

- <https://software.opensuse.org/download/package?package=nextcloud-desktop&project=network>

### Tor Browser

```shell
sudo zypper install torbrowser-launcher
torbrowser-launcher
```

### Proton VPN

```shell
flatpak install flathub com.protonvpn.www
```

### 1Password

```shell
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo zypper ar https://downloads.1password.com/linux/rpm/stable/x86_64 1password
sudo zypper install 1password 1password-cli
```

Quellen:

- <[https://support.1password.com/install-linux/#centos-fedora-or-red-hat-enterprise-linux](https://1password.community/discussion/comment/624348/#Comment_624348)>

### Visual Studio Code

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh
sudo zypper install code
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
cat > AnyDesk-OpenSUSE.repo << "EOF" 
[anydesk]
name=AnyDesk OpenSUSE - stable
baseurl=http://rpm.anydesk.com/opensuse/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF

zypper addrepo --repo AnyDesk-OpenSUSE.repo
```

```shell
sudo zypper refresh
sudo zypper install anydesk
```

Quellen:

- <http://rpm.anydesk.com/howto.html>

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

```shell
sudo zypper ar https://packages.microsoft.com/yumrepos/edge edge
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper refresh
sudo zypper install microsoft-edge-stable
```

Quellen:

- <https://lanbugs.de/howtos/linux/opensuse-microsoft-edge-installieren/>

### Google Chrome

```shell
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
sudo zypper refresh
sudo zypper install google-chrome-stable
```

Quellen:

- <https://www.heiko-evermann.com/so-installierst-du-google-chrome-auf-suse-leap/?utm_content=cmp-true>

### Logitech Receiver 

```shell
sudo zypper install solaar solaar-udev
```

### Podman

```shell
sudo zypper install podman
```

### Gnome Boxes

```shell
sudo zypper install gnome-boxes
```

### Ausweis App 2

```shell
flatpak install flathub de.bund.ausweisapp.ausweisapp2
```

```shell
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --add-port=24727/udp --permanent
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --list-ports  --permanent
sudo firewall-cmd --reload
```

### Master PDF Editor

```shell
sudo zypper ar http://repo.code-industry.net/rpm/master-pdf-editor.repo
sudo rpm --import http://repo.code-industry.net/deb/pubmpekey.asc
sudo zypper refresh
sudo zypper install master-pdf-editor
```

Quellen: 

- <https://code-industry.net/masterpdfeditor-help/package-installation-from-remote-repository/>

### VueScan Scanner Software

```shell
sudo flatpak install flathub com.hamrick.VueScan
```
```shell
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --add-source-port=5353/udp --permanent #MDNS
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --add-source-port=8610/udp --permanent #Canon
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --add-source-port=8612/udp --permanent #Canon
DefaultZone=$(sudo firewall-cmd --get-default-zone) && sudo firewall-cmd --zone=$DefaultZone --list-source-ports  --permanent
sudo firewall-cmd --reload
```
