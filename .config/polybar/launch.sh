#!/bin/sh

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar mybar -c /etc/polybar/config &

echo "Polybar runing..."
