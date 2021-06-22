#!/bin/bash
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Das ist eine Pre-installationsscript für ArchLinux!"
echo "Er wird nach dem chroot dein Benutzer erstellt,"
echo "und auch die Programme sowie denn Desktopoberfläche installieren."
echo "Dabei wird er auch Schritt für Schritt eingerichtet."
echo ""
echo "Dieser Script ist aktuell noch in der [Beta]"
echo "Deshalb kann es auch zur Problemen kommen!"
echo ""
echo "Wenn du damit einverstanden bist, bitte auf"
echo "Enter drücken oder mit (Strg+C) abbrechen"
read n
echo "============================================="
clear
echo ""
echo "Wie soll dein PC heißen?"
read pcname
echo "$pcname" > /etc/hostname
echo "Ihr PC/Laptop heißt $pcname !"
echo "Welche Sprache sollte ihr ArchLinux anzeigen?"
echo "Geben sie die gewünschte locale ein!"
echo "Beispiel: de_DE.UTF-8"
read locale
echo LANG=$locale > /etc/locale.conf
echo "Sie haben die Locale $locale ausgewählt!"
echo "Bei diesem Punkt musst du denn gewünschte Sprache auskommentieren!"
echo "Beispiel: '#de_DE.UTF-8 zu de_DE.UTF-8'"
read n
nano /etc/locale.gen
locale-gen
echo "Tastaturlayout wird konfiguriert!"
echo "Geben sie ihr gewünschte Tastaturlayout ein!"
echo "Beispiel: de-latin1"
read keymap
echo KEYMAP=$keymap > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf
echo "Fertig, sie haben $keymap ausgewählt!"
echo ""
echo "Zeitzone wird eingerichtet!"
echo "Bitte geben sie ihre Zeitzone an!"
echo "Beispiel: Europe/Berlin"
read timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
echo "Fertig, sie haben $timezone eingegeben!"
echo ""
echo "Jetzt wird Grub installiert"
echo "Hast du ein EFI oder Legacy PC? efi/legacy"
echo "Unterschied ist: EFI modern - Legacy alt"
read grub
if [[ $grub == "legacy" ]]; then
  echo ""
  echo "Legacy wurde ausgewählt!"
  fdisk -l
  echo "Bitte wählen sie ihre Root Partition aus!"
  read root
  echo "Sie haben $root ausgewählt!"
  echo "Grub wird installiert..."
  pacman -S grub
  grub-install /dev/$root
  break
  grub-mkconfig -o /boot/grub/grub.cfg
elif [[ $grub == "efi" ]]; then
  echo ""
  echo "EFI wurde ausgewählt!"
  echo "Grub wird installiert..."
  pacman -S grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot
  break
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi

pacman -Sy
mkinitcpio -p linux
echo "passwort für 'root'"
passwd
echo ""
echo "Wie soll der User heißen?"
read user
echo "Der gewünschte User heißt $user !"
useradd -m -g users -s /bin/bash "$user"
echo "Passwort für $user"
passwd $user
gpasswd -a "$user" wheel
gpasswd -a "$user" games
gpasswd -a "$user" audio
gpasswd -a "$user" video
pacman -S sudo
echo "Bitte tragen sie ihr $user unter dem 'root' ein!"
echo "$user  ALL=(ALL) ALL"
echo ""
read n
nano /etc/sudoers
systemctl enable --now fstrim.timer
pacman -S acpid dbus avahi cups cronie
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable --now cronie
systemctl enable --now systemd-timesyncd.service
date
hwclock -w
date
pacman -S xorg-server xorg-xinit -y
echo "Welcher Grafiktreiber soll installiert werden? ;)"
echo "Für Nvidia Grafikkarten: (nvidia)"
echo "Für AMD Grafikarten (xf86-video-amdgpu und amdvlk)"
echo "Intel ist Standartmäßig installiert (Enter drücken)"
echo "Enter drücken falls kein Treiber installiert werden soll."
read gpu
pacman -S "$gpu" -y
localectl set-x11-keymap de pc105
pacman -S ttf-dejavu
echo ""
clear
echo ""
echo "Jetzt wird die Desktopoberfläche installert..."
echo "Es gibst zur Auswahl: GNOME, KDE, XFCE(empfohlen)"
echo "Welche Oberfläche willst du haben? gnome/kde/xfce"
read deskenv
if [[ $deskenv == "gnome" ]]; then
  echo "GNOME wird installert!"
  pacman -S gnome gnome-extra gdm pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session networkmanager gnome-software-packagekit-plugin flatpak fwupd -y
  systemctl enable gdm
  systemctl enable NetworkManager.service
elif [[ $deskenv == "kde" ]]; then
  echo "KDE wird installert!"
  pacman -S plasma kde-applications sddm pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session networkmanager packagekit-qt5 flatpak fwupd-y
  systemctl enable sddm
  systemctl enable NetworkManager.service
elif [[ $deskenv == "xfce" ]]; then
  echo "XFCE wird installert!"
  pacman -S xfce4 xfce4-goodies lightdm networkmanager network-manager-applet lightdm-gtk-greeter lightdm-gtk-greeter-settings pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session pavucontrol xfce4-whiskermenu-plugin fwupd -y
  systemctl enable lightdm
  systemctl enable NetworkManager
else
  echo ""
  echo "Es wird keine Desktopoberfläche installiert!"
fi
echo ""
echo "Willst du auch die Standard Programme installieren (empfohlen)"
echo "Es beinhaltet denn Firefox(Internet), Thunderbird(Email), VLC/MPV(Multimedia)"
echo "Libreoffice(Office), Fonts und usw. Es erspart auch die unötigen installationen."
echo "ja/nein"
read standpro
if [[ $standpro == "ja" ]]; then
  echo "Standartprogramme werden installiert..."
  pacman -S firefox firefox-i18n-de thunderbird thunderbird-i18n-de libreoffice-fresh vlc mpv jre8-openjdk unzip git wget xz p7zip ufw iptables adobe-source-sans-pro-fonts aspell-de hunspell-de languagetool libmythes mythes-de ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid ttf-liberation ttf-ubuntu-font-family -y
elif [[ $standpro == "nein"]]; then
  echo "Standard Programme werden nicht installiert!"
else
  echo "Tippfehler..."
fi
echo "Du hast ArchLinux erfolgreich installiert!"
echo "Ich hoff dass es dir gefallen wird..."
echo "und Vielen Dank zur Nutzung meines Script´s"
read n
