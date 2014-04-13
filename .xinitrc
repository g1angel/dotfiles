#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Redirect console messages from applications started in X to .xsession-errors
# instead of the console.
errfile="$HOME/.xsession-errors"
cp /dev/null "$errfile" 2> /dev/null
chmod 600 "$errfile"
exec > "$errfile" 2>&1

# Start urxvt server
# urxvtd -q -f -o

# Source .xprofile if it exists and is readable.
[ -r $HOME/.xprofile ] && . $HOME/.xprofile

# Start the correct x session
# To use start with: xinit arg
case "$1" in
    "lxde") exec ck-launch-session startlxde ;;
    "gnome") exec ck-launch-session gnome-session ;;
    "openbox") exec ck-launch-session dbus-launch --sh-syntax --exit-with-session openbox-session ;;
    "xmonad") 
        xsetroot -cursor_name left_ptr
        nitrogen --restore &
        numlockx &
        exec ck-launch-session dbus-launch --sh-syntax --exit-with-session  xmonad ;;
    "ratpoison")
        xsetroot -cursor_name left_ptr
        nitrogen --restore &
        numlockx &
        exec ck-launch-session dbus-launch --sh-syntax --exit-with-session  ratpoison ;;
    "subtle") 
        xsetroot -cursor_name left_ptr
        nitrogen --restore &
        numlockx &
        exec ck-launch-session dbus-launch --sh-syntax --exit-with-session subtle ;;
    *) exec openbox-session ;;
    # *) exec dbus-launch --sh-syntax --exit-with-session openbox-session ;;
    # *) exec dbus-launch --sh-syntax --exit-with-session enlightenment_start ;;
    #*) exec ck-launch-session dbus-launch --sh-syntax --exit-with-session twindy ;;
esac
