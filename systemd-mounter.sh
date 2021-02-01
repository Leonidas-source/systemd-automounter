#!/bin/bash
error() {
  clear
  echo "You must be root to execute this script"
  exit
}
user_check() {
  clear
  [ `/usr/bin/whoami` != root ] && error
}
reg() {
  clear
  echo "Do you have a folder for your partition?
  1) Yes
  2) No"
  read arg
  [ "$arg" == "1" ] && i_have_a_folder
  [ "$arg" == "2" ] && i_dont_have_a_folder
}
i_dont_have_a_folder() {
  echo "set your folder"
  read -e arg0
  mkdir -p $arg0
  echo "folder created"
  sleep 1s
  clear
  arg3=$(readlink -f $arg0)
  lsblk
  echo "Set your partition"
  read arg4
  UUID=$(lsblk -f $arg4 -o UUID | sed s/"UUID"/""/g | sed '/^$/d;s/[[:blank:]]//g')
  echo "What=/dev/disk/by-uuid/$UUID" | cat >> test.mount
  echo "Where=$arg3" | cat >> test.mount
  filesystem=$(lsblk -f $arg4 -o FSTYPE | sed s/"FSTYPE"/""/g | sed '/^$/d;s/[[:blank:]]//g')
  echo "Type=$filesystem" | cat >> test.mount
  echo "" | cat >> test.mount
  echo "[Install]" | cat >> test.mount
  echo "WantedBy=multi-user.target" | cat >> test.mount
}
i_have_a_folder() {
  echo "set folder"
  read -e arg2
  clear
  arg3=$(readlink -f $arg2)
  lsblk
  echo "Set your partition"
  read arg4
  UUID=$(lsblk -f $arg4 -o UUID | sed s/"UUID"/""/g | sed '/^$/d;s/[[:blank:]]//g')
  echo "What=/dev/disk/by-uuid/$UUID" | cat >> test.mount
  echo "Where=$arg3" | cat >> test.mount
  filesystem=$(lsblk -f $arg4 -o FSTYPE | sed s/"FSTYPE"/""/g | sed '/^$/d;s/[[:blank:]]//g')
  echo "Type=$filesystem" | cat >> test.mount
  echo "" | cat >> test.mount
  echo "[Install]" | cat >> test.mount
  echo "WantedBy=multi-user.target" | cat >> test.mount
}
set -e
path_to_systemd=/etc/systemd/system
current_directory=$(pwd)
user_check
echo "[Unit]" | cat >> test.mount
clear
echo "set your description"
read arg5
echo "Description=$arg5" | cat >> test.mount
echo "" | cat >> test.mount
echo "[Mount]" | cat >> test.mount
reg
new_file=$(echo $arg3 | sed "s+/+-+g")
echo $new_file | cat >> 1
split 1 -d -b 1
rm x00 
cat x?? >> final
rm x??
new_name=$(cat final)
mv test.mount $new_name'.mount'
rm 1
mv $new_name'.mount' $path_to_systemd
cd $path_to_systemd
systemctl enable $new_name'.mount'
cd $current_directory
rm final
