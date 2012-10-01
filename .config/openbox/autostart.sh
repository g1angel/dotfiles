#!/bin/bash 

#set background image with ImageMagick
#exec nitrogen --set-scaled "/home/share/pictures/organized/trip/us20/detour/california/P0002631.jpg" &
exec nitrogen --restore &

#turn on num lock
exec numlockx &

#enable gnome screensaver
#exec gnome-screensaver &

# enable compisitor
#exec xcompmgr &

# start launcher bar
#exec adeskbar &
exec tint2 &
#exec python /usr/share/system-config-printer/applet.py &
#exec volwheel &
exec startconky ~/.conkyrc-openbox &
