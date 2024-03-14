#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  scp -r "ubuntu changes/libevview3/" ${wks_user}@${r}:/tmp/
  scp -r "ubuntu changes/Yaru/" ${wks_user}@${r}:/tmp/
  
  ssh ${wks_user}@${r} "sudo rm -f /usr/lib/x86_64-linux-gnu/libevview3.so*"
  ssh ${wks_user}@${r} "sudo rm -f /usr/share/themes/Yaru/gtk-3.0/gtk.css"
  ssh ${wks_user}@${r} "sudo rm -f /usr/share/themes/Yaru/gtk-3.20/gtk.css"
  
  ssh ${wks_user}@${r} "sudo mv /tmp/libevview3/libevview3.so* /usr/lib/x86_64-linux-gnu/"
  ssh ${wks_user}@${r} "sudo mv /tmp/Yaru/gtk-3.0/gtk.css /usr/share/themes/Yaru/gtk-3.0/gtk.css"
  ssh ${wks_user}@${r} "sudo mv /tmp/Yaru/gtk-3.20/gtk.css /usr/share/themes/Yaru/gtk-3.20/gtk.css"

  ssh ${wks_user}@${r} "gsettings set org.gnome.desktop.interface overlay-scrolling false"
  
done
