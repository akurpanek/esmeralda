# esmeralda-fedora38

## Pre-Installation

---

## Initiale Installation

---

## Post Instllation

### Fractional Scaling aktivieren

https://www.omglinux.com/how-to-enable-fractional-scaling-fedora/

## Hostnamen anpassen
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
