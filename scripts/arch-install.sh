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
echo "Teil 'b' ist im chroot aktiv. (!Script neu starten!)"
echo ""
echo "Welcher Teil soll möchtest du machen? a/b"
read teil
echo "============================================="
if [[ $teil == "a" ]]; then
  echo "Die Partitionierung"
  echo ""
  fdisk -l
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
    fdisk -l
    echo "Stehen dort 2 Partitionen bei der Platte "$part" ? ja/nein"
    read ant
    if [[ $ant == "ja" ]]; then
      clear
      echo "Dann machen wir weiter..."
      echo ""
      fdisk -l
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
    fdisk -l
    echo "Stehen dort 3 Partitionen bei der Platte "$part" ? ja/nein"
    read ant
    if [[ $ant == "ja" ]]; then
      clear
      echo "Dann machen wir weiter..."
      echo ""
      fdisk -l
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
