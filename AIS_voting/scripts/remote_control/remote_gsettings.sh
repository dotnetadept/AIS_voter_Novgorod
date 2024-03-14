#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  ssh ${wks_user}@${r} "PID=$(pgrep gnome-session);export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | cut -d= -f2-);gsettings set org.gnome.mutter check-alive-timeout 0"

done







