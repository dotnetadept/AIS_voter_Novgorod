#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  ssh ${wks_user}@${r} "sudo systemctl --no-wall reboot"

done
