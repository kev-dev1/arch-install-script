#!/bin/bash
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
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
echo "Teil 'a' wird partitionierung als auch Basis eingerichtet."
echo "Teil 'b' ist nach dem neustart."
echo ""
echo "Welcher Teil soll möchtest du machen? a/b"
read teil
echo "============================================="
if ["$teil" == "a"]
then
  echo "Die Partitionierung"
  lsblk
  echo "Auf welche Festplatte/SSD willst du ArchLinux installieren"
  echo "Es sollte so aussehen: /dev/sda, /dev/nvme0n1, /dev/mmcblk0"
  read part
  parted $part mklabel gpt
  echo "EFI Partition wird erstellt!"
  sgdisk $part -n=1:0:+1024M -t=1:ef00
  echo "SWAP Speicher wird erstellt!"
  swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
	swapsize=$((${swapsize}/1000))"M"
	sgdisk ${device} -n=2:0:+${swapsize} -t=2:8200
  echo "Root Partition wird erstellt!"
  sgdisk $part -n=3:0:0
  echo ""
  clear
  echo "Fertig"
  lsblk
  echo "Stehen dort 3 Partitionen bei der Platte $part ? ja/nein"
  read ant
  if ["$ant" == "ja"]
    then
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
    elif ["$ant" == "nein"]
      echo "Bitte starten sie den Script neu oder Partitionieren sie es selber!"
      echo "Bei Probleme mit dem Script, melden sie es bitte in Github es!"
    else
      echo ""
      echo "Tippfehler"

      pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd bash-completion wpa_supplicant netctl dialog lvm2
      echo ""
      echo "Hast du ein Intel oder AMD CPU verbaut? intel/amd"
      read cpu
      if ["$cpu" == "intel"]
      then
        pacman --root /mnt -S intel-ucode
      elif ["$cpu" == "amd"]
        pacman --root /mnt -S amd-ucode
      else
        echo ""
        echo "Tippfehler"
      fi
    genfstab -Up /mnt > /mnt/etc/fstab
    arch-chroot /mnt
  fi

elif ["$teil" == "b"]
then
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
fi
