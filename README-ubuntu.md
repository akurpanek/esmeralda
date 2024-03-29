# Ubuntu 22.04 LTS auf dem Lenovo Yoga 7 16IAH7

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
Festlattenkapazität | 1,0 TB

---

## Pre-Installation

---

## Initiale Installation

---

## Post Instllation

Quellen:

- <>

### Hostnamen anpassen

```shell
sudo hostnamectl set-hostname "esmeralda"
```

### Fractional Scaling aktivieren

Fractional scaling is enabled by default in Ubuntu 22.04 and newer.

Quellen:

- <https://www.omglinux.com/how-to-enable-fractional-scaling-fedora/>  

### System aktualisieren

```shell
sudo apt update && \
sudo apt upgrade -y && \
sudo apt autoremove -y && \
sudo snap refresh
```

### Ubuntu Full Desktop installieren

```shell
# Move from minimal desktop to full desktop
sudo apt remove --auto-remove -y ubuntu-desktop-minimal
sudo apt install -y ubuntu-desktop
```

```shell
## Move from full desktop to minimal desktop
#sudo apt remove --auto-remove -y ubuntu-desktop
#sudo apt install -y ubuntu-desktop-minimal
```

### Ubuntu Software reparieren

```shell
sudo killall snap-store && \
sudo snap remove snap-store && \
sudo snap install snap-store
```

### Snapshot erstellen

___Noch an Ubuntu anzupassen!___

```shell
sudo snapper create --description "Vor den Änderungen nach der Installation" --print-number
```
```shell
> 3
```

### Intel Alder Lake PCH-P High Definition Audio konfigurieren

Folgende Modulparameter durch erstellen der Datei `/etc/modprobe.d/alsa-base.conf`konfigurieren:

```shell
# Fix tinny and quiet sound on new Lenovo 7i
options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin
```

Quellen:

- <https://askubuntu.com/questions/1243369/sound-card-not-detected-ubuntu-20-04-sof-audio-pci>
- <https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture/Troubleshooting#Intel_Cannon_Lake_PCH_cAVS>

---

### Intel i915 and Kernel 6.2

Quellen:

- <https://askubuntu.com/questions/1480917/i915-missing-firmware-error-message-during-kernel-6-2-0-26-installation-on-xubun>
- <https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915/dg2_huc_gsc.bin>

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

### Nützliche Pakete

```shell
sudo apt install -y \
  neofetch \
  backintime-qt \
  vim \
  git \
  curl
```

### ZSH and OhMyZsh

```shell
sudo apt-get -y install zsh git
chsh -s $(which zsh)
touch ~/.zshrc # Suppress configuration dialog
rm ~/.zshrc # force configuration dialog
```

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Quellen:

- <https://ohmyz.sh/#install>
- <https://www.heise.de/ratgeber/Einfuehrung-in-die-Z-Shell-Maximaler-Komfort-im-Terminal-4690876.html>
- <https://www.heise.de/select/ct/2016/16/1470382401977334>

### Gnome Evolution

```shell
# Fix GDBus.Error:org.freedesktop.DBus.Error.UnknownMethod in Ubuntu 22.04 and Firefox
sudo apt remove --auto-remove -y thunderbird
sudo apt install -y evolution
```

```shell
# Replace thunderbird with gnome evolution
sudo apt install -y xdg-desktop-portal-gnome
```

### Nextcloud Desktop

```shell
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt update
sudo apt-get install -y nextcloud-desktop nextcloud-desktop-cmd nautilus-nextcloud
```

```shell
mkdir -p ~/Nextcloud/Pictures
mkdir -p ~/Nextcloud/Music
mkdir -p ~/Nextcloud/Videos
mkdir -p ~/Nextcloud/Documents
mkdir -p ~/Nextcloud/Public
mkdir -p ~/Nextcloud/Desktop
mkdir -p ~/Nextcloud/Templates
mkdir -p ~/Nextcloud/Desktop
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

### Wine 

```shell
sudo apt-get install -y wine-stable
sudo dpkg --add-architecture i386 && sudo apt update -y && sudo apt install -y wine32 
```

Quellen:

- <https://wiki.ubuntuusers.de/Wine/>

### Cryptomator

```shell
sudo add-apt-repository -y ppa:sebastian-stenzel/cryptomator
sudo apt update -y
sudo apt install -y cryptomator
```

Quellen:

- <https://cryptomator.org/de/downloads/linux/>
- <https://launchpad.net/~sebastian-stenzel/+archive/ubuntu/cryptomator>

### Tor Browser

```shell
sudo apt-get install -y torbrowser-launcher
```

```shell
# Hotfix "Download Error: 404"
# <https://askubuntu.com/questions/1445050/updating-tor-screwed-up-my-client-download-error-404>
if [ ! -f /usr/lib/python3/dist-packages/torbrowser_launcher/common.py.backup ]; then \
sudo cp /usr/lib/python3/dist-packages/torbrowser_launcher/{common.py,common.py.backup}
fi

sudo sed -i 's|self.language =.*|self.language = "ALL"|g' /usr/lib/python3/dist-packages/torbrowser_launcher/common.py
sudo sed -i 's|"/tor-browser_"|"/tor-browser"|g' /usr/lib/python3/dist-packages/torbrowser_launcher/common.py

# Uncomment 'language' in the file manualy

rm -rf ~/{cache,.local/share,.config}/torbrowser
ln -s ~/.local/share/torbrowser/tbb/x86_64{tor-browser,tor-browser_ALL}
```

```shell
torbrowser-launcher
```

### Mullvad VPN

```shell
wget -O MullvadVPN-latest.deb https://mullvad.net/de/download/app/deb/latest
sudo apt install -y ./MullvadVPN-latest.deb
```

### 1Password

```shell
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

sudo apt update -y && sudo apt install -y 1password 1password-cli
```

Quellen:

- <https://support.1password.com/install-linux/#debian-or-ubuntu>

### Gnome Boxes and KVM

```shell
sudo apt install -y gnome-boxes virt-manager
sudo ln -s /usr/bin/qemu-system-x86_64 /usr/bin/qemu
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
sudo setfacl -m user:`id -un`:rw /var/run/libvirt/libvirt-sock
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

### Visual Studio Code

```shell
# Install Visual Studio Code
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders
```

```shell
# Set default text editor
xdg-mime default code.desktop text/plain
```

```shell
# Install extensions
code \
  --install-extension VisualStudioExptTeam.vscodeintellicode \
  --install-extension ms-vscode.PowerShell \
  --install-extension ms-vscode.azure-repos \
  --install-extension MS-CEINTL.vscode-language-pack-de
  --install-extension mhutchie.git-graph \
  --install-extension GitHub.vscode-github-actions \
  --install-extension GitHub.vscode-pull-request-github \
```

Quellen:

- <https://code.visualstudio.com/docs/setup/linux>
- <https://code.visualstudio.com/docs/editor/extension-marketplace>

### PowerShell

```shell
## Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Delete the the Microsoft repository GPG keys file
rm packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y powershell
# Start PowerShell
pwsh
```

Quellen:

- <https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3>

### Steam

```shell
sudo apt install -y steam-installer
```

### AnyDesk Remote-Desktop

```shell
# Add repository key to Trusted software providers list
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
# Add the repository:
sudo echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
# Update apt cache:
sudo apt update
# Install anydesk:
sudo apt install anydesk
```

Quellen:

- <http://deb.anydesk.com/howto.html>

### Spotify for Linux

```shell
sudo snap install --stable spotify
```

Quellen:

- <https://www.spotify.com/de/download/linux/>

### Zoom Desktop Client für Linux

```shell
sudo apt install -y ./zoom_amd64.deb
```

Quellen:

- <https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux>

### Firefox Browser



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
wget --quiet -O - http://repo.code-industry.net/deb/pubmpekey.asc | sudo tee /etc/apt/keyrings/pubmpekey.asc
echo "deb [signed-by=/etc/apt/keyrings/pubmpekey.asc arch=$( dpkg --print-architecture )] http://repo.code-industry.net/deb stable main" | sudo tee /etc/apt/sources.list.d/master-pdf-editor.list
sudo apt install -y master-pdf-editor-5
```

Quellen: 

- <https://code-industry.net/masterpdfeditor-help/package-installation-from-remote-repository/>

### VueScan Scanner Software

```shell
sudo flatpak install flathub com.hamrick.VueScan
```

### Signal Messenger

```shell
sudo snap install --stable signal-desktop
```

### WhatsApp Messenger

```shell
sudo snap install --stable whatsapp-for-linux
```


### Inkscape, GIMP, Scribus
```shell
sudo apt install -y inkscape
sudo apt install -y gimp gimp-help-de
sudo apt install -y scribus scribus-template scribus-doc texlive-latex-recommended
```

### GDM Background and Resolution
```shell
sudo apt-get install libglib2.0-dev-bin

wget -q https://raw.githubusercontent.com/PRATAP-KUMAR/ubuntu-gdm-set-background/main/ubuntu-gdm-set-background && chmod +x ubuntu-gdm-set-background

sudo ./ubuntu-gdm-set-background --image /home/akurpanek/.local/share/backgrounds/LenovoWallPaper.jpg
#sudo update-alternatives --quiet --set gdm-theme.gresource /usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource
```

```shell
sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config/monitors.xml
```

Quellen:

- <https://github.com/PRATAP-KUMAR/ubuntu-gdm-set-background>


### Media

```shell
flatpak install flathub org.gnome.World.PikaBackup
sudo apt install libavcodec-extra ffmpeg
sudo apt install seahorse-nautilus
```


### Double Commander

```shell
echo 'deb http://download.opensuse.org/repositories/home:/Alexx2000:/doublecmd-svn/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:Alexx2000:doublecmd-svn.list
curl -fsSL https://download.opensuse.org/repositories/home:Alexx2000:doublecmd-svn/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Alexx2000_doublecmd-svn.gpg > /dev/null
sudo apt update
sudo apt install doublecmd-gtk
```


### Swap File

```shell
sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile
sudo btrfs property set /swapfile compression none
sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Quellen:

- <https://btrfs.readthedocs.io/en/latest/Swapfile.html>
