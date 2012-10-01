#!/bin/bash
#todate.sh calculates how many days are left till the end of time/world
#Copyright (C) 2008  Josiah

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

function todate ()
{
    end_date=$(date +%s -d "$1")
    today=$(date +%s)
    seconds_in_day=$((60 * 60 * 24))

    diff_days=$((($end_date - $today) / $seconds_in_day))

    if (($diff_days > 1)) || (($diff_days == 0))
    then
        plrl_days="s"
    else
        plrl_days=""
    fi
}

todate "Oct 21, 2011"
msg_world="The world ends in $diff_days day$plrl_days probably"
todate "May 21, 2011"
msg_time="Time ends in $diff_days day$plrl_days"
case $1 in
    "time") printf "${msg_time}" ;;
    *) printf "${msg_world}" ;;
esac
#notify-send -u critical "The end of the world" "$msg_world"
#notify-send -u critical "The end of time" "$msg_time"

#zenity --warning --text "$msg_time\nand\n$msg_world" &
