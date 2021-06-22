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
read n
echo "============================================="
clear
echo ""
echo "Die Partitionierung"
echo ""
fdisk -l
echo "Auf welche Festplatte/SSD willst du ArchLinux installieren"
echo "Es sollte so aussehen: /dev/(sda), /dev/(nvme0n1), /dev/(mmcblk0)"
echo "Bitte nur die im Klammer sind eingeben"
read part
echo "Hast du ein EFI oder Legacy PC? efi/legacy"
echo "Unterschied ist: EFI modern - Legacy alt"
read pctype
if [[ $pctype == "legacy" ]]; then
  echo "Legacy ausgewählt"
  echo "Root Partition wird erstellt!"
  sgdisk /dev/$part -n=3:0:0
  echo "SWAP Speicher wird erstellt!"
  swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  swapsize=$((${swapsize}/1000))"M"
  sgdisk $part -n=2:0:+${swapsize} -t=2:8200
  echo "Fertig"
elif [[ $pctype == "efi" ]]; then
  echo "EFI ausgewählt"
  parted /dev/$part mklabel gpt
  echo "EFI Partition wird erstellt!"
  sgdisk /dev/$part -n=1:0:+1024M -t=1:ef00
  echo "SWAP Speicher wird erstellt!"
  swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
  swapsize=$((${swapsize}/1000))"M"
  sgdisk /dev/$part -n=2:0:+${swapsize} -t=2:8200
  echo "Root Partition wird erstellt!"
  sgdisk /dev/$part -n=3:0:0
  echo ""
  clear
  echo "Fertig"
else
  echo ""
  echo "Tippfehler, nochmal eingeben!"
fi

fdisk -l
echo "Stehen dort gewisse Partitionen bei der Platte '/dev/$part' ? ja/nein"
read parted
if [[ $parted == "ja" ]]; then
  echo "Dann machen wir weiter..."
  echo ""
  fdisk -l
  echo "Geben sie bitte die Partition für 'root' ein! /dev/sdXX"
  read root
  mkfs.ext4 /dev/$root
  mount /dev/$root /mnt
  echo "Ihr 'root' Partition ist '/dev/$root'"
  echo ""
  echo "Geben sie bitte die Partition für 'boot' ein! /dev/sdXX"
  echo "Gilt bei 'EFI' nur, normal bleibt er in root drin."
  read boot
  mkfs.fat -F32 /dev/$boot
  mkdir /mnt/boot/
  mount /dev/$boot /mnt/boot/
  echo "Ihr 'boot' Partition ist '/dev/$boot'"
  echo ""
  echo "Geben sie bitte die Partition für 'swap' ein! /dev/sdXX"
  read swap
  mkswap /dev/$swap
  swapon /dev/$swap
  echo "Ihr 'swap' Partition ist '/dev/$swap'"
elif [[ $parted == "nein" ]]; then
  echo "Bitte starten sie den Script neu oder Partitionieren sie es selber!"
  echo "Bei Probleme mit dem Script, melde es bitte in Github umbedingt!"
else
  echo ""
  echo "Tippfehler"
fi
clear
echo "Jetzt wird Grub installiert, dabei wird nochmal gefragt..."
echo "Hast du ein EFI oder Legacy PC? efi/legacy"
echo "Unterschied ist: EFI modern - Legacy alt"
read grub
if [[ $grub == "legacy" ]]; then
  echo ""
  echo "Legacy wurde ausgewählt!"
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
  grub-install --target=x86_64-efi --efi-directory=/boot/
  break
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi

echo "Die ArchLinux Base wird installiert..."
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd bash-completion wpa_supplicant netctl dialog lvm2 -y
echo ""
echo "Hast du ein Intel oder AMD CPU verbaut? intel/amd"
read cpu
if [[ $cpu == "intel" ]]; then
  echo "Intel CPU wurde ausgewählt!"
  pacman --root /mnt -S intel-ucode -y
elif [[ $cpu == "amd" ]]; then
  echo "AMD CPU wurde ausgewählt"
  pacman --root /mnt -S amd-ucode -y
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi

echo "Die Partitiontabelle werden erstellt"
genfstab -Up /mnt > /mnt/etc/fstab
echo "Bitte kontrolliere ob die Partitionen richtig eingetragen sind!"
cat /mnt/etc/fstab
echo "Sind die Partitionen richtig drin eingetragen? ja/nein"
read fspart
if [[ $fspart == "ja" ]]; then
  echo ""
  echo "Sie werden jetzt in den Arch-chroot gebracht, bitte laden sie den Script..."
  echo "erneurt herunter und starten sie 'Teil b' für weitere einrichtungen."
  arch-chroot /mnt
elif [[ $fspart == "nein" ]]; then
  echo "Wiederholen sie den Script neu"
  echo "oder melden sie es in GitHub es Bitte"
else
  echo ""
  echo "Tippfehler, nochmal bitte!"
fi
