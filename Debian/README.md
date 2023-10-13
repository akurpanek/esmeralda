# Debian 12 GNOME

Quellen:

- <https://docs.github.com/de/get-started/writing-on-github>
- <https://google.github.io/styleguide/shellguide.html#s4-comments>
- <https://github.com/yusuftaufiq/dotfiles/blob/main/.chezmoiscripts/run_once_before_00-install-terminal-packages.sh>
- <https://github.com/nourkagha/dotfiles>

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
grep -iq '^options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin' /etc/modprobe.d/snd.conf \
  || echo "options snd-sof-intel-hda-common hda_model=alc287-yoga9-bass-spk-pin" \
  | sudo tee -a /etc/modprobe.d/snd.conf
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

sudo snapper -c home set-config 'TIMELINE_CREATE=yes'
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

#### Vorinstallierte Software deinstallieren

```shell
# Spiele deinstallieren
sudo apt remove --purge --autoremove -y gnome-games
```

#### Terminalsoftware installieren

```shell
sudo apt install -y \
  build-essential lshw neofetch vim needrestart \
  wget curl gpg git apt-transport-https
```

#### Kernel aus Backports aktualisieren

Quellen:

- <https://wiki.debian.org/Firmware#Debian_12_.28bookworm.29_and_later>

```shell
# Kernel aus Backports installieren
sudo apt install -y -f -t bookworm-backports linux-image-amd64 firmware-linux #linux-headers-amd64
```
```shell
# Firmwware-Dateien von git.kernel.org herunterladen
mkdir ~/firmware
wget -P ~/firmware/ -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' \
  https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915/
sudo mv ~/firmware/*.bin /lib/firmware/i915/
rmdir ~/firmware
```
```shell
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
```
```shell
# Plymouth Konfigurtion anpassen
sudo sed -i 's/^#\[Daemon\].*/[Daemon]/' /etc/plymouth/plymouthd.conf
if $(cat /etc/plymouth/plymouthd.conf | grep -iq '^DeviceScale')
then
  sudo sed -i 's/^DeviceScale.*/DeviceScale=2/' /etc/plymouth/plymouthd.conf
else
  echo "DeviceScale=2" | sudo tee -a /etc/plymouth/plymouthd.conf
fi
```
```shell
# Initramfs aktualisieren
sudo update-initramfs -c -k all
```
```shell
# Grub Konfiguration anpassen
grep -iq '^GRUB_CMDLINE_LINUX_DEFAULT.*splash' /etc/default/grub \
  || sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"$#\1 splash"#' /etc/default/grub
grep -iq '^GRUB_CMDLINE_LINUX_DEFAULT.*loglevel' /etc/default/grub \
  || sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"$#\1 loglevel=0"#' /etc/default/grub
```
```shell
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

## Kryptographie

#### GnuPG und SSH eirichten

Quellen:

- <https://man.cx/gpg-agent>
- <https://www.kuketz-blog.de/gnupg-schluesselerstellung-und-smartcard-transfer-nitrokey-teil2/>
- <https://www.kuketz-blog.de/gnupg-public-key-authentifizierung-nitrokey-teil3/>
- <https://wiki.archlinux.org/title/GNOME/Keyring#Disabling>
- <https://wiki.archlinux.org/title/Paperkey>

```shell
# GnuPGP und Tools installieren
sudo apt install -y gnupg paperkey qrencode
```
```shell
# Backup der Schlüssel erstellen
mkdir -p ~/.gnupg/backup_akurpanek@mailbox.org
gpg --armor --output privkey_akurpanek@mailbox.org.asc --export-secret-key akurpanek@mailbox.org
gpg --armor --output subkeys_akurpanek@mailbox.org.asc --export-secret-subkeys akurpanek@mailbox.org
gpg --armor --output pubkey_akurpanek@mailbox.org.asc --export akurpanek@mailbox.org
gpg --export-ownertrust > akurpanek@mailbox.org.txt
```
```shell
# Einfaches Backup der Schlüssel erstellen
mkdir -p ~/.gnupg/backup_akurpanek@mailbox.org
gpg --armor --output privkey_akurpanek@mailbox.org.asc --export-secret-keys akurpanek@mailbox.org
gpg --armor --output pubkey_akurpanek@mailbox.org.asc --export akurpanek@mailbox.org
gpg --export-ownertrust > akurpanek@mailbox.org.txt
```
```shell
# Widerufzertifiakt erstellen
gpg --output revoke_akurpanek@mailbox.org.asc --gen-revoke akurpanek@mailbox.org
```
```shell
# Schlüssel als Print-Variante exportieren
gpg --export-secret-key akurpanek@mailbox.org \
  | paperkey --output privkey_akurpanek@mailbox.org.paper.asc
```
```shell
# SSH-Unterstützung im GPG-Agent aktivieren
grep -iq '^enable-ssh-support' ~/.gnupg/gpg-agent.conf \
  || echo "enable-ssh-support" \
  | tee -a ~/.gnupg/gpg-agent.conf
```
```shell
# Umgebungsvariablen des SSH-Agenten anpassen
grep -iqP '^[ \t]*export SSH_AUTH_SOCK=' ~/.bashrc \
  || cat >> ~/.bashrc <<EOL

# Set environemnt to enable the Ssh Agent Support
# <https://man.cx/gpg-agent#heading6>
unset SSH_AGENT_PID
if [ "\${gnupg_SSH_AUTH_SOCK_by:-0}" -ne \$\$ ]; then
  export SSH_AUTH_SOCK="\$(gpgconf --list-dirs agent-ssh-socket)"
fi
EOL
```
```shell
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
## Fractional Scaling X11 aktivieren
#gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
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
```
```shell
# Flathub Repository hinzufügen
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
```shell
# GNOME Software zurrücksetzen
killall gnome-software
rm -rf ~/.cache/gnome-software
```
```shell
# Flatseal installieren
sudo flatpak install -y flathub com.github.tchx84.Flatseal
```

#### GNOME Themes Qt und GTK

Quellen:

- <https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications>

```shell
sudo apt install -y adwaita-qt
```

#### GNOME Shell Extension installieren

Quellen:

- <https://extensions.gnome.org/>
- <https://pypa.github.io/pipx/installation/>
- <https://itsfoss.com/gnome-shell-extensions/>

```shell
# pipx installieren und zu $PATH hinzufügen
sudo apt install -y pipx
pipx ensurepath
```
```shell
# Gnome Extensions CLI installieren
pipx install gnome-extensions-cli --system-site-packages
```
```shell
# Gnome Shell Extensions installieren
gnome-extensions-cli --filesystem install dash-to-dock@micxgx.gmail.com \
  appindicatorsupport@rgcjonas.gmail.com \
  eye-extended@als.kz \
  lockkeys@vaina.lt \
  tiling-assistant@leleat-on-github \
  launch-new-instance@gnome-shell-extensions.gcampax.github.com
```
```shell
# Gnome Shell Extensions aktivieren
gnome-extensions-cli --dbus enable dash-to-dock@micxgx.gmail.com \
  appindicatorsupport@rgcjonas.gmail.com \
  eye-extended@als.kz \
  lockkeys@vaina.lt \
  tiling-assistant@leleat-on-github \
  launch-new-instance@gnome-shell-extensions.gcampax.github.com
```

## Software Installation

### Passwortmanager

#### 1Password installieren

Quellen:

- <https://support.1password.com/install-linux/#debian-or-ubuntu>

```shell
# GPG Schlüssel für 1Password Repository hinzufügen
wget -qO- https://downloads.1password.com/linux/keys/1password.asc \
  | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
```
```shell
# 1Password Repository hinzufügen
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' \
  | sudo tee /etc/apt/sources.list.d/1password.list
```
```shell
# Debsig-Überprüfungsrichtlinie hinzufügen
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
  | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc \
  | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
```
```shell
# 1Password GUI und CLI installieren
sudo apt update -y && \
  sudo apt install -y 1password 1password-cli
```

### Office und Texteditoren

#### Typora installieren

```shell
# GPG Schlüssel für Typora Repository hinzufügen
wget -qO-  https://typora.io/linux/public-key.asc \
  | sudo gpg --dearmor --output /usr/share/keyrings/typora.gpg
```
```shell
# Typora Repository hinzufügen
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/typora.gpg] https://typora.io/linux ./' \
  | sudo tee /etc/apt/sources.list.d/typora.list
```
```shell
# Typora installieren
sudo apt-get update -y && \
  sudo apt-get install -y typora
```

### Grafik und DTP


### Container- und Virtualisierung

#### KVM/QEMU und XLC installieren

Quellen:

- <https://wiki.debian.org/SystemVirtualization>
- <https://wiki.debian.org/KVM>
- <https://wiki.debian.org/LXC>
- <https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/>

```shell
# QEMU, KVM, LXC, libvirt, spice und GUI virt-manager installieren
sudo apt install -y qemu-system libvirt-daemon-system lxc virt-manager
```
```shell
# Nested Virtualization aktivieren
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
```
```shell
# Nested Virtualization permanent aktivieren
grep -iq '^options kvm_intel nested=1' /etc/modprobe.d/kvm.conf \
  || echo "options kvm_intel nested=1" \
  | sudo tee -a /etc/modprobe.d/kvm.conf
```
```shell
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
```
```shell
# Cryptomator konfigurieren
flatpak override --user org.cryptomator.Cryptomator --reset
flatpak override --user org.cryptomator.Cryptomator --filesystem=host
```
```shell
# Cryptomator Alias setzen
alias signal='flatpak run org.cryptomator.Cryptomator'
grep -iq '^alias cryptomator=' ~/.bash_aliases \
  || echo "alias cryptomator='flatpak run org.cryptomator.Cryptomator'" \
  | tee -a ~/.bash_aliases
```
### Development

#### Visual Studio Code einrichten

Quellen:

- <https://code.visualstudio.com/docs/setup/linux>
- <https://wiki.debian.org/VisualStudioCode>

```shell
# Repository und GPG-Key installieren
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
grep -iq 'packages.microsoft.com/repos/code stable main' /etc/apt/sources.list.d/vscode.list \
  || echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee -a /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
```
```shell
# VSCode und Voraussetzungen installieren
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders
```
```shell
# VSCode als Standard Editor festlegen
#xdg-mime default code.desktop text/plain
#sudo update-alternatives --set editor /usr/bin/code
sudo update-alternatives --install /usr/bin/editor editor $(which code) 10
```

#### Entwicklungstools einrichten

```shell
sudo apt install -y meld
```

### Instant Messaging

#### WhatsApp Messenger einrichten

```shell
# WhatsApp Desktop installieren
sudo flatpak install -y flathub io.github.mimbrero.WhatsAppDesktop
```
```shell
# WhatsApp Desktop konfigurieren
flatpak override --user io.github.mimbrero.WhatsAppDesktop --reset
```
```shell
# WhatsApp Desktop Alias setzen
alias whatsapp='flatpak run io.github.mimbrero.WhatsAppDesktop'
grep -iq '^alias whatsapp=' ~/.bash_aliases \
  || echo "alias whatsapp='flatpak run io.github.mimbrero.WhatsAppDesktop'" \
  | tee -a ~/.bash_aliases
```

#### Signal Messenger einrichten

```shell
# Signal Desktop installieren
sudo flatpak install -y flathub org.signal.Signal
```
```shell
# Signal Desktop konfigurieren
flatpak override --user org.signal.Signal --reset
flatpak override --user org.signal.Signal --filesystem=host
flatpak override --user org.signal.Signal --env=SIGNAL_USE_TRAY_ICON=1
```
```shell
# Signal Desktop Alias setzen
alias signal='flatpak run org.signal.Signal'
grep -iq '^alias signal=' ~/.bash_aliases \
  || echo "alias signal='flatpak run org.signal.Signal'" \
  | tee -a ~/.bash_aliases
```
