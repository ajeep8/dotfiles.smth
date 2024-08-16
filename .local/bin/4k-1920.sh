#!/bin/bash

w=`xrandr | grep '*' | awk '{print $1}' | cut -d 'x' -f1`

if [ "$w" -eq 3840 ]; then
    xfconf-query -c xsettings -p /Xft/DPI -s 96
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 24
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s 40
    xrandr -s 1920x1080
    sed -i -e 's/height = 40/height = 24/' -e 's/pixelsize=20/pixelsize=10/' ~/.config/polybar/config
    sed -i -e 's/top_padding 40/top_padding 24/' -e 's/bottom_padding 44/bottom_padding 27/' ~/.config/bspwm/bspwmrc
    sed -i 
    echo 1920x1080
else
    xfconf-query -c xsettings -p /Xft/DPI -s 192
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 40
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s 80
    xrandr -s 3840x2160
    sed -i -e 's/height = 24/height = 40/' -e 's/pixelsize=10/pixelsize=20/' ~/.config/polybar/config
    sed -i -e 's/top_padding 24/top_padding 40/' -e 's/bottom_padding 27/bottom_padding 44/' ~/.config/bspwm/bspwmrc
    echo 3840x2160
fi

#sed -i 's/^FontSize=.*$/FontSize=20/' ~/.config/fcitx/conf/fcitx-classic-ui.config
fcitx -r > /dev/null 2>&1 | grep -v Receive

