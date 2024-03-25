#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 bspwm|xfwm"
  exit 1
fi

if [ "$1" = "xfwm"  ]; then 
  echo 'xfwm'
  rm -rf ~/.cache/sessions/xfce4-session-*
  sed -i 's/^Hidden=false/Hidden=true/' ~/.config/autostart/bspwm.desktop
  cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml.xfwm ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
  #sudo cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml.xfwm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
  reboot
elif [ "$1" = "bspwm"  ]; then 
  echo 'bspwm'
  rm -rf ~/.cache/sessions/xfce4-session-*
  sed -i 's/^Hidden=true/Hidden=false/' ~/.config/autostart/bspwm.desktop
  cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml.bspwm ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
  #sudo cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml.bspwm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
  reboot
else
  echo "Usage: $0 bspwm|xfwm"
fi
