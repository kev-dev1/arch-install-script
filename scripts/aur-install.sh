#!/bin/bash
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Dieser Script installiert die ArchLinux AUR-Repository"
echo "dabei wird auch pamac installiert"
echo "============================================="
echo ""
echo "Yay wird installiert!"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
echo ""
echo "Yay ist fertig installiert!"
rm -rf yay
clear
echo "Pamac wird installiert!"
yay -S pamac-aur
echo ""
echo "Pamac ist fertig installiert"
echo "Viel Spaß mit der AUR-Repository!"
read a
