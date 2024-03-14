#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  scp bundle.tar.xz  ${wks_user}@${r}:/home/${wks_user}/

  ssh ${wks_user}@${r} "$(< deploy.sh)"

done
