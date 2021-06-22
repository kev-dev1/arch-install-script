#!/bin/bash
destDIR="scripts"
echo "============================================="
echo "GitHub:   https://github.com/kev-dev1"
echo "Website:  https://kev-dev1.github.io"
echo "Script:   https://github.com/kev-dev1/arch-install-script"
echo ""
echo "Dieser Script erfordert eine Internetverbindung, weil er die Pakete"
echo "für die Basis und Desktopoberfläche runterladen muss."
echo ""
echo "Dieser Script ist aktuell noch in der [Beta]"
echo "Deshalb kann es auch zur Problemen kommen wärend der Installion!"
echo ""
echo "Wenn du damit einverstanden bist, bitte auf"
echo "Enter drücken oder abbrechen"
read n
echo "Dieser Script ist auf 3 Teile gegliedert:"
echo "Teil 'a' wird Partitionierung als auch die Basis installiert."
echo "Teil 'b' ist im chroot aktiv. (Nochmal runterladen per GIT und starten)"
echo "Teil 'c' wird die Arch-Aur-Packetmanager aktiviert und installiert. (Optional)"
echo ""
echo "Welcher Teil soll möchtest du machen? a/b/c"
read teil
echo "============================================="
if [[ $teil == "a" ]]; then
  clear
  bash $destDIR/arch-install.sh
elif [[ $teil == "b" ]]; then
  clear
  bash $destDIR/pre-install.sh
elif [[ $teil == "c" ]]; then
  clear
  bash $destDIR/aur-install.sh
else
  echo ""
  echo "Tippfehler, nochmal eingeben!"
fi
