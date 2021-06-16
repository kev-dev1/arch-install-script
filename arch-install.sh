#!/bin/bash
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Dieser Script erfordert eine Internetverbindung, weil er die Pakete"
echo "für die Basis und Desktopoberfläche runterladen tut."
echo ""
echo "Dieser Script ist aktuell noch in der [Beta]"
echo "Deshalb kann es auch Probleme bereiten"
echo ""
echo "Wenn du damit einverstanden bist, bitte auf"
echo "Enter drücken oder abbrechen"
read n
echo "Dieser Script ist auf 2 Teile gegliedert:"
echo "Teil 'a' wird Partitionierung als auch die Basis eingerichtet."
echo "Teil 'b' ist im chmod aktiv. (!Script neu starten!)"
echo ""
echo "Welcher Teil soll möchtest du machen? a/b"
read teil
echo "============================================="
if [[ $teil == "a" ]]; then
  echo "Die Partitionierung"
  echo ""
  lsblk
  echo "Auf welche Festplatte/SSD willst du ArchLinux installieren"
  echo "Es sollte so aussehen: /dev/sda, /dev/nvme0n1, /dev/mmcblk0"
  read part
  echo "Hast du ein EFI oder Legacy PC? efi/legacy"
  echo "Unterschied ist: EFI modern - Legacy alt"
  read grub
  if [[ $grub == "legacy" ]]; then
    echo "Legacy ausgewählt"
    echo "Root Partition wird erstellt!"
    sgdisk $part -n=3:0:0
    echo "SWAP Speicher wird erstellt!"
    swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  	swapsize=$((${swapsize}/1000))"M"
  	sgdisk $part -n=2:0:+${swapsize} -t=2:8200
    echo "Fertig"
    lsblk
    echo "Stehen dort 2 Partitionen bei der Platte "$part" ? ja/nein"
    read ant
    if [[ $ant == "ja" ]]; then
      clear
      echo "Dann machen wir weiter..."
      echo ""
      lsblk
      echo "Geben sie bitte die Partition für 'root' ein! /dev/sdXX"
      read root
      mkfs.ext4 $root
      mount $root /mnt
      echo "Geben sie bitte die Partition für 'swap' ein! /dev/sdXX"
      read swap
      mkswap $swap
      swapon $swap
      echo "Grub wird installiert..."
      pacman -S grub
      grub-install $root
      break
      grub-mkconfig -o /boot/grub/grub.cfg
    elif [[ $ant == "nein" ]]; then
      echo "Bitte starten sie den Script neu oder Partitionieren sie es selber!"
      echo "Bei Probleme mit dem Script, melden sie es bitte in Github es!"
    else
      echo ""
      echo "Tippfehler"
    fi

  elif [[ $grub == "efi" ]]; then
    echo "EFI ausgewählt"
    parted $part mklabel gpt
    echo "EFI Partition wird erstellt!"
    sgdisk $part -n=1:0:+1024M -t=1:ef00
    echo "SWAP Speicher wird erstellt!"
    swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  	swapsize=$((${swapsize}/1000))"M"
  	sgdisk $part -n=2:0:+${swapsize} -t=2:8200
    echo "Root Partition wird erstellt!"
    sgdisk $part -n=3:0:0
    echo ""
    clear
    echo "Fertig"
    lsblk
    echo "Stehen dort 3 Partitionen bei der Platte "$part" ? ja/nein"
    read ant
    if [[ $ant == "ja" ]]; then
      clear
      echo "Dann machen wir weiter..."
      echo ""
      lsblk
      echo "Geben sie bitte die Partition für 'root' ein! /dev/sdXX"
      read root
      mkfs.ext4 $root
      mount $root /mnt
      echo "Geben sie bitte die Partition für 'boot' ein! /dev/sdXX"
      read boot
      mkfs.fat -F32 $boot
      mkdir /mnt/boot/
      mount $boot /mnt/boot
      echo "Geben sie bitte die Partition für 'swap' ein! /dev/sdXX"
      read swap
      mkswap $swap
      swapon $swap
      echo "Grub wird installiert..."
      pacman -S grub efibootmgr
      grub-install --target=x86_64-efi --efi-directory=/boot
      break
      grub-mkconfig -o /boot/grub/grub.cfg
    elif [[ $ant == "nein" ]]; then
      echo "Bitte starten sie den Script neu oder Partitionieren sie es selber!"
      echo "Bei Probleme mit dem Script, melden sie es bitte in Github es!"
    else
      echo ""
      echo "Tippfehler"
    fi

  pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd bash-completion wpa_supplicant netctl dialog lvm2
  echo ""
  echo "Hast du ein Intel oder AMD CPU verbaut? intel/amd"
  read cpu
  if [[ $cpu == "intel" ]]; then
    pacman --root /mnt -S intel-ucode
  elif [[ $cpu == "amd" ]]; then
    pacman --root /mnt -S amd-ucode
  else
    echo ""
    echo "Tippfehler"
  fi

  genfstab -Up /mnt > /mnt/etc/fstab
  arch-chroot /mnt

elif [[ $teil == "b" ]]; then
  echo "Wie soll dein PC heißen?"
  read pcname
  echo "$pcname" > etc/hostname
  echo LANG=de_DE.UTF-8 > /etc/locale.conf
  echo de_DE.UTF-8 > /etc/locale.gen
  locale-gen
  echo KEYMAP=de-latin1 > /etc/vconsole.conf
  echo FONT=lat9w-16 >> /etc/vconsole.conf
  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  pacman -Sy
  mkinitcpio -p linux
  echo "passwort für 'root'"
  passwd
  echo ""
  echo "Wie soll der User heißen?"
  read user
  useradd -m -g users -s /bin/bash "$user"
  echo Passwort für $user
  passwd $user
  pacman -S sudo
  echo $user  ALL=(ALL) ALL >> /etc/sudoers
  gpasswd -a "$ant" wheel
  gpasswd -a "$ant" games
  gpasswd -a "$ant" audio
  gpasswd -a "$ant" video
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
  pacman -S xorg-server xorg-xinit
  echo "Welcher Grafiktreiber soll installiert werden? ;)"
  echo "Für Nvidia Grafikkarten: (nvidia)"
  echo "Für AMD Grafikarten (xf86-video-amdgpu und amdvlk)"
  echo "Intel ist Standartmaeßig installiert"
  echo "Enter drücken falls kein Treiber installiert werden soll."
  read gpu
  pacman -S "$gpu"
  localectl set-x11-keymap de pc105 nodeadkeys
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
    pacman -S gnome gnome-extra gdm pipewire pipewire-pulse pipewire-alsa piewire-jack pipewire-media-session networkmanager gnome-software-packagekit-plugin flatpak
    systemctl enable gdm
    systemctl enable NetworkManager.service
  elif [[ $deskenv == "kde" ]]; then
    echo "KDE wird installert!"
    pacman -S plasma kde-applications sddm pipewire pipewire-pulse pipewire-alsa piewire-jack pipewire-media-session networkmanager packagekit-qt5 flatpak
    systemctl enable sddm
    systemctl enable NetworkManager.service
  elif [[ $deskenv == "xfce" ]]; then
    echo "XFCE wird installert!"
    pacman -S xfce4 xfce4-goodies lightdm networkmanager network-manager-applet lightdm-gtk-greeter lightdm-gtk-greeter-settings pipewire pipewire-pulse pipewire-alsa piewire-jack pipewire-media-session pavucontrol xfce4-whiskermenu-plugin
    systemctl enable lightdm
    systemctl enable NetworkManager.service
  else
    echo "Desktop umgebung wird nicht mit installiert."
  fi
  echo "Willst du auch die Standard Programme installieren (empfohlen)"
  echo "Es beinhaltet denn Firefox(Internet), Thunderbird(Email), VLC/MPV(Multimedia)"
  echo "Libreoffice(Office), Fonts und usw. Es erspart auch die unötigen installationen."
  echo "ja/nein"
  read standpro
  if [[ $standpro == "ja" ]]; then
    pacman -S firefox firefox-i18n-de thunderbird thunderbird-i18n-de libreoffice-fresh vlc mpv jre8-openjdk unzip git wget xz p7zip ufw iptables adobe-source-sans-pro-fonts aspell-de hunspell-de languagetool libmythes mythes-de ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid ttf-liberation ttf-ubuntu-font-family
  elif [[ $standpro == "nein" ]]; then
    echo "Standard Programme werden nicht installiert!"
  fi

  echo "Du hast ArchLinux erfolgreich installiert!"
  echo "Ich hoff dass es dir gefallen wird..."
  echo "und Vielen Dank zur Nutzung meines Script´s"
  echo "MFG Kev-Dev1"
  echo "PS: Es gibt noch ein Script wo Yay installiert wird!"
  read a

else
  echo "Tippfehler, bitte korrigieren!!"
fi
