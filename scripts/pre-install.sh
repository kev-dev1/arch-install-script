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
echo "============================================="
read n

# PC Name Setup
clear
echo ""
echo "Wie soll dein PC heißen?"
echo ""
read pcname
echo ""
echo "$pcname" > /etc/hostname
echo "Ihr PC/Laptop heißt $pcname !"
echo ""

# Language Setup
clear
echo ""
echo "Welche Sprache sollte ihr ArchLinux anzeigen?"
echo "Geben sie die gewünschte locale ein!"
echo "Beispiel: de_DE.UTF-8"
echo ""
read locale
echo LANG=$locale > /etc/locale.conf
echo ""
echo "Sie haben die Locale $locale ausgewählt!"
echo ""
echo "Bei diesem Punkt musst du denn gewünschte Sprache auskommentieren!"
echo "Beispiel: '#de_DE.UTF-8 zu de_DE.UTF-8'"
read n
nano /etc/locale.gen
locale-gen
echo ""

# Keymap Setup
clear
echo ""
echo "Tastaturlayout wird konfiguriert!"
echo "Geben sie ihr gewünschte Tastaturlayout ein!"
echo "Beispiel: de-latin1"
echo ""
read keymap
echo KEYMAP=$keymap > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf
echo ""
echo "Fertig, sie haben $keymap ausgewählt!"
echo ""

# Timezone Setup
clear
echo ""
echo "Zeitzone wird eingerichtet!"
echo ""
echo "Bitte geben sie ihre Zeitzone an!"
echo "Beispiel: Europe/Berlin"
echo ""
read timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
echo ""
echo "Fertig, sie haben $timezone eingegeben!"
echo ""

# Grub Setup With os-prober
clear
echo ""
echo "Jetzt wird Grub installiert"
echo "Hast du ein EFI oder Legacy PC? efi/legacy"
echo "Unterschied ist: EFI modern - Legacy alt"
echo ""
read grub
if [[ $grub == "legacy" ]]; then
  clear
  echo ""
  echo "Legacy wurde ausgewählt!"
  fdisk -l
  echo ""
  echo "Bitte wählen sie ihre Root Partition aus!"
  echo ""
  read root
  echo ""
  echo "Sie haben $root ausgewählt!"
  echo ""
  echo "Grub wird installiert..."
  pacman -S grub os-prober
  grub-install /dev/$root
  grub-mkconfig -o /boot/grub/grub.cfg
elif [[ $grub == "efi" ]]; then
  clear
  echo ""
  echo "EFI wurde ausgewählt!"
  echo ""
  echo "Grub wird installiert..."
  pacman -S grub efibootmgr os-prober
  grub-install --target=x86_64-efi --efi-directory=/boot
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi

# Linux Kernel Installer
clear
echo ""
echo "Kernel wird installiert"
pacman -Sy
mkinitcpio -p linux
echo ""
echo "Der Linux Kernel ist installert"
echo ""
echo "Passwort für 'root'"
passwd
echo ""

# User Profile Creator
clear
echo ""
echo "Wie soll der User heißen?"
echo ""
read user
echo ""
echo "Der gewünschte User heißt $user !"
useradd -m -g users -s /bin/bash "$user"
echo ""
echo "Passwort für $user"
echo ""
passwd $user
gpasswd -a "$user" wheel
gpasswd -a "$user" games
gpasswd -a "$user" audio
gpasswd -a "$user" video
echo ""
pacman -S sudo
echo "Bitte tragen sie ihr $user unter dem 'root' ein!"
echo "$user  ALL=(ALL) ALL"
echo ""
read n
nano /etc/sudoers
echo ""

# Bussystem and Time/Date Setup
clear
echo ""
echo "Bussystem Dienste werden Installiert"
pacman -S acpid dbus avahi cups cronie
echo ""
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable --now cronie
systemctl enable --now systemd-timesyncd.service
systemctl enable --now fstrim.timer
date
hwclock -w
date

# Xorg Setup
clear
echo ""
echo "Xorg wird installiert"
pacman -S xorg-server xorg-xinit -y
echo ""
echo "Xorg ist fertig installiert"
echo ""

# Graphic Card Setup
clear
echo ""
echo "Welcher Grafiktreiber soll installiert werden? ;)"
echo ""
echo "Für Nvidia Grafikkarten: (nvidia)"
echo "Für AMD Grafikarten (xf86-video-amdgpu und amdvlk)"
echo "Intel ist Standartmäßig installiert (Enter drücken)"
echo ""
echo "Enter drücken falls kein Treiber installiert werden soll."
echo ""
read gpu
pacman -S "$gpu" -y
echo ""

#  Set Keymap
clear
localectl set-x11-keymap de pc105
pacman -S ttf-dejavu
echo ""

# Desktop Envirement Setup
clear
echo ""
echo "Jetzt wird die Desktopoberfläche installert..."
echo "Es gibst zur Auswahl: GNOME, KDE, XFCE(empfohlen)"
echo "Welche Oberfläche willst du haben? gnome/kde/xfce"
echo ""
read deskenv
if [[ $deskenv == "gnome" ]]; then
  clear
  echo ""
  echo "GNOME wird installert!"
  echo ""
  pacman -S gnome gnome-extra gdm pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session networkmanager gnome-software-packagekit-plugin flatpak fwupd bluez bluez-utils -y
  systemctl enable gdm
  systemctl enable NetworkManager
  systemctl enable bluetooth
elif [[ $deskenv == "kde" ]]; then
  clear
  echo ""
  echo "KDE wird installert!"
  echo ""
  pacman -S plasma kde-applications sddm pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session networkmanager packagekit-qt5 flatpak fwupd bluez bluez-utils -y
  systemctl enable sddm
  systemctl enable NetworkManager
  systemctl enable bluetooth
elif [[ $deskenv == "xfce" ]]; then
  clear
  echo ""
  echo "XFCE wird installert!"
  echo ""
  pacman -S xfce4 xfce4-goodies lightdm networkmanager network-manager-applet lightdm-gtk-greeter lightdm-gtk-greeter-settings pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-media-session pavucontrol xfce4-whiskermenu-plugin fwupd bluez bluez-utils blueberry libcanberra sound-theme-freedesktop -y
  systemctl enable lightdm
  systemctl enable NetworkManager
  systemctl enable bluetooth
else
  echo ""
  echo "Es wird keine Desktopoberfläche installiert!"
fi

# Standard Programm Install
clear
echo ""
echo "Willst du auch die Standard Programme installieren (empfohlen)"
echo "Es beinhaltet denn Firefox(Internet), Thunderbird(Email), VLC/MPV(Multimedia)"
echo "Libreoffice(Office), Fonts und usw. Es erspart auch die unötigen installationen."
echo ""
echo "ja/nein"
echo ""
read standpro
if [[ $standpro == "ja" ]]; then
  clear
  echo ""
  echo "Standartprogramme werden installiert..."
  echo ""
  pacman -S firefox firefox-i18n-de thunderbird thunderbird-i18n-de libreoffice-fresh vlc mpv jre8-openjdk unzip git wget xz p7zip ufw iptables adobe-source-sans-pro-fonts aspell-de hunspell-de languagetool libmythes mythes-de ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid ttf-liberation ttf-ubuntu-font-family -y
  echo ""
  echo "Standartprogramme wurde fertig Installiert"
  echo ""
elif [[ $standpro == "nein" ]]; then
  echo ""
  echo "Standard Programme werden nicht installiert!"
else
  echo "Tippfehler..."
fi

# Setup Finish
clear
echo ""
echo "Du hast ArchLinux erfolgreich installiert!"
echo "Ich hoff dass es dir gefallen wird..."
echo "und Vielen Dank zur Nutzung meines Script´s"
echo ""
read n
