#!/bin/sh

ID="$((/lib/gluon/label_mac.sh 2>/dev/null || echo "000000000000") | sed -e s/://g)"
FILE="/tmp/${ID}.tgz"

wget -O ${FILE} "https://erx.4830.org/index.php/download?id=${ID}"
if [ $? -eq 0 ]; then
  sysupgrade --restore-backup ${FILE} ||:
  uci set system.@system[0].compat_version='2.0'
  uci commit system
  gluon-reconfigure ||:
  sync
  sleep 2
  /etc/init.d/done boot
  reboot
fi
