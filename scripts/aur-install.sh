#!/bin/bash
"============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Dieser Script installiert die ArchLinux AUR-Repository"
echo "dabei wird auch pamac installiert"
echo ""
"============================================="
echo "Yay wird installiert!"
pacman -S --needed git base-devel -y
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
echo "Yay ist fertig installiert!"
rm -rf yay
clear
echo "Pamac wird installiert!"
yay -S pamac-aur
echo "Pamac ist fertig installiert"
echo "Viel Spaß mit der AUR-Repository!"
read a
