#!/bin/bash
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Dieser Script richtet denn Grundaufbau des Systems."
echo "dabei wird am Anfang erst Partitioniert und danach der Basis installiert."
echo ""
echo "Dieser Script ist aktuell noch in der [Beta]"
echo "Deshalb kann es auch Probleme bereiten"
echo ""
echo "Wenn du damit einverstanden bist, bitte auf"
echo "Enter drücken oder mit (Strg+C) abbrechen"
echo "============================================="
read n
clear
echo ""
echo "Die Partitionierung"
echo ""
fdisk -l
echo ""
echo "Auf welche Festplatte/SSD willst du ArchLinux installieren"
echo "Es sollte so aussehen: /dev/(sda), /dev/(nvme0n1), /dev/(mmcblk0)"
echo "Bitte nur die im Klammer sind eingeben"
echo ""
read part
echo ""
echo "Hast du ein EFI oder Legacy PC? efi/legacy"
echo "Unterschied ist: EFI modern - Legacy alt"
echo ""
read pctype
if [[ $pctype == "legacy" ]]; then
  clear
  echo "Legacy ausgewählt"
  echo ""
  echo "Root Partition wird erstellt!"
  sgdisk /dev/$part -n=3:0:0
  echo "SWAP Speicher wird erstellt!"
  swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  swapsize=$((${swapsize}/1000))"M"
  sgdisk $part -n=2:0:+${swapsize} -t=2:8200
  echo "Fertig"
elif [[ $pctype == "efi" ]]; then
  clear
  echo "EFI ausgewählt"
  echo ""
  parted /dev/$part mklabel gpt
  echo "EFI Partition wird erstellt!"
  echo ""
  sgdisk /dev/$part -n=1:0:+1024M -t=1:ef00
  echo "SWAP Speicher wird erstellt!"
  echo ""
  swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  swapsize=$((${swapsize}/1000))"M"
  sgdisk /dev/$part -n=2:0:+${swapsize} -t=2:8200
  echo "Root Partition wird erstellt!"
  echo ""
  sgdisk /dev/$part -n=3:0:0
  echo ""
  echo "Fertig"
else
  echo ""
  echo "Tippfehler, nochmal eingeben!"
fi

clear
echo ""
fdisk -l
echo ""
echo "Stehen dort gewisse Partitionen bei der Platte '/dev/$part' ? ja/nein"
echo ""
read parted
if [[ $parted == "ja" ]]; then
  echo ""
  echo "Dann machen wir weiter..."
  echo ""
  fdisk -l
  echo ""
  echo "Geben sie bitte die Partition für 'root' ein! /dev/sdXX"
  echo ""
  read root
  mkfs.ext4 /dev/$root
  mount /dev/$root /mnt
  echo ""
  echo "Ihr 'root' Partition ist '/dev/$root'"
  echo ""
  echo "Geben sie bitte die Partition für 'boot' ein! /dev/sdXX"
  echo "Gilt bei 'EFI' nur, normal bleibt er in root drin."
  echo ""
  read boot
  mkfs.fat -F32 /dev/$boot
  mkdir /mnt/boot/
  mount /dev/$boot /mnt/boot/
  echo ""
  echo "Ihr 'boot' Partition ist '/dev/$boot'"
  echo ""
  echo "Geben sie bitte die Partition für 'swap' ein! /dev/sdXX"
  echo ""
  read swap
  mkswap /dev/$swap
  swapon /dev/$swap
  echo "Ihr 'swap' Partition ist '/dev/$swap'"
  echo ""
elif [[ $parted == "nein" ]]; then
  echo "Bitte starten sie den Script neu oder Partitionieren sie es selber!"
  echo "Bei Probleme mit dem Script, melde es bitte in Github umbedingt!"
else
  echo ""
  echo "Tippfehler"
fi

clear
echo "Die ArchLinux Base wird installiert..."
echo ""
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd bash-completion wpa_supplicant netctl dialog lvm2 -y
echo ""
echo "Hast du ein Intel oder AMD CPU verbaut? intel/amd"
echo ""
read cpu
if [[ $cpu == "intel" ]]; then
  echo ""
  echo "Intel CPU wurde ausgewählt!"
  echo ""
  pacman --root /mnt -S intel-ucode -y
elif [[ $cpu == "amd" ]]; then
  echo ""
  echo "AMD CPU wurde ausgewählt"
  echo ""
  pacman --root /mnt -S amd-ucode -y
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi

clear
echo "Die Partitiontabelle werden erstellt"
genfstab -Up /mnt > /mnt/etc/fstab
echo ""
echo "Bitte kontrolliere ob die Partitionen richtig eingetragen sind!"
echo ""
cat /mnt/etc/fstab
echo ""
echo "Sind die Partitionen richtig drin eingetragen? ja/nein"
echo ""
read fspart
if [[ $fspart == "ja" ]]; then
  echo ""
  echo "Sie werden jetzt in den Arch-chroot gebracht, bitte laden sie den Script..."
  echo "erneurt herunter und starten sie 'Teil b' für weitere einrichtungen."
  echo ""
  arch-chroot /mnt
elif [[ $fspart == "nein" ]]; then
  echo ""
  echo "Wiederholen sie den Script neu"
  echo "oder melden sie es in GitHub es Bitte"
  echo ""
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
  echo ""
fi
