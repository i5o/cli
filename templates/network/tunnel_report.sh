#!/bin/bash

function report {
  portinterval=$(grep -oP "(?<=\-M)(.*?) " /etc/tunnel)
  portssh=$((portinterval + 22))
  portweb=$((portinterval + 80))
  portcouchdb=$((portinterval + 84))
  portnewcouchdb=$((portinterval + 82))
  portmunin=$((portinterval + 49))
  while read -r channel; do
    export gitter_channel="$channel"
    treehouses feedback "$(sed -r "s/.* (.*?)$/\1/g" /etc/tunnel | tail -n1):$portinterval\n22:$portssh 80:$portweb 2200:$portnewcouchdb 4949:$portmunin 5984:$portcouchdb"
  done < /etc/tunnel_report_channels.txt
  echo "report"
}


prevStatus=$(cat /tmp/prev_ssh_status 2>/dev/null || echo "offline")
if ping -q -c 3 -W 1 1.1.1.1 >/dev/null; then
  echo "rpi is online, was $prevStatus"
  if [ "$prevStatus" = "offline" ]; then
    echo "online" > /tmp/prev_ssh_status
    report
  fi
else
  echo "rpi is offline, was $prevStatus"
  echo "offline" > /tmp/prev_ssh_status
fi
