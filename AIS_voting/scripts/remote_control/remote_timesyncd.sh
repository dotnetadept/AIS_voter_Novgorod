#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  ssh ${wks_user}@${r} "sudo sed -i 's/#NTP=/NTP=172.16.10.11/g' /etc/systemd/timesyncd.conf"

done
