#!/usr/bin/bash
work_dir="/home/u/deputy"
cfg_file="/home/u/deputy/data/flutter_assets/assets/cfg/app_settings.json"
bundle_file="/home/u/bundle.tar.xz"

#extract
if [ -d ${work_dir}_new/ ]
then
  rm -rf ${work_dir}_new
fi
mkdir ${work_dir}_new
if [ -f ${bundle_file} ]
then
  tar -xf ${bundle_file} -C ${work_dir}_new/
  rm -f ${bundle_file}

  #stop deputy
  killall deputy

  #backup
  if [ -d ${work_dir}_bak/ ]
  then
    rm -rf ${work_dir}_bak
  fi
  if [ -d ${work_dir}/ ]
  then
    mv ${work_dir} ${work_dir}_bak
  fi

  #deploy
  mv ${work_dir}_new/bundle/ ${work_dir}/
  chmod a+x ${work_dir}/deputy
  rm -rf ${work_dir}_new

  #change cfg
  host_id=`hostname | cut -c2- | awk '{printf("%03d\n", $1)}'`
  cfg_line=`sed -n '/terminal_id/=' ${cfg_file}`
  sed -i "${cfg_line}s/\b[0-9]\{3\}\b/${host_id}/" ${cfg_file}
  
  #reboot host
  sudo systemctl --no-wall reboot
fi
