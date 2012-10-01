#!/bin/bash

function calc_bw
{
    bps=$1
    if [[ $bps -lt $kilo ]]
    then
        if [[ $2 == "bits" ]]
        then
            bstr="b/s"
        else
            bstr="B/s"
        fi
        ret_str=`printf "%.0f %s" $bps $bstr`
    elif [[ $bps -lt $((kilo * kilo)) ]]
    then
        if [[ $2 == "bits" ]]
        then
            bstr="kb/s"
        else
            bstr="KB/s"
        fi
        ret_str=`printf "%.1f %s" $(echo "$bps/$kilo" | bc -l) $bstr`
    else
        if [[ $2 == "bits" ]]
        then
            bstr="Mb/s"
        else
            bstr="MB/s"
        fi
        ret_str=`printf "%.1f %s" $(echo "$bps/($kilo*$kilo)" | bc -l) $bstr`
    fi
    printf "${ret_str}"
}

function show_help
{
    cat <<EOF
Usage: $0 [-i interface] [-p path] [-b]
    -i interface    Interface to watch
    -p path         Path to write to
    -b              Display in bits per second

    -h              Display this help
EOF
    exit
}
function exit_func
{
    rm $uptmp 2>/dev/null
    rm $downtmp 2>/dev/null
    rm "$outpath/bwup" 2>/dev/null
    rm "$outpath/bwdown" 2>/dev/null

    printf "Exiting...\n"
    exit
}

oldpids=($(ps -fu $USER |grep $0|gawk '$0 !~ /(grep|gawk|'"$$"')/ {if ($8 ~ /sh/) {print $2}}'))
for i in ${oldpids[@]}
do
    kill $i 2>/dev/null
done
[[ -z $1 ]] && show_help
while [[ -n $1 ]]
do
    case ${1} in
        '-i') interface=$2; shift 2;;
        '-p') outpath=$2; shift 2;;
        '-b') bits='bits'; shift;;
        *) show_help ;;
    esac
done
trap 'exit_func' 0 SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM

if [[ $bits == "bits" ]]
then
    mulnum=8
    kilo=1000
else
    mulnum=1
    kilo=1024
fi
old_upstr=
old_downstr=
uptmp=$(mktemp /dev/shm/bwup.XXXXXXXX)
downtmp=$(mktemp /dev/shm/bwdown.XXXXXXXX)

ln -s $uptmp "$outpath/bwup"
ln -s $downtmp "$outpath/bwdown"

#while [[ -n $(pgrep -u $USER lxsession) && -n $(pgrep -u $USER conky) ]] 
while [[ -n $(pgrep -u $USER conky) ]] 
do
    tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)

    tx_bps=$((tx_bytes-tx_bytes_old))
    rx_bps=$((rx_bytes-rx_bytes_old))

    tx_bytes_old=$tx_bytes
    rx_bytes_old=$rx_bytes

    ((tx_bps*=mulnum))
    ((rx_bps*=mulnum))
    up_str=$(calc_bw $tx_bps $bits)
    down_str=$(calc_bw $rx_bps $bits)
    if [[ $up_str != $old_upstr ]]
    then
        printf "${up_str}"  > "$outpath/bwup"
    fi
    if [[ $down_str != $old_downstr ]]
    then
        printf "${down_str}" > "$outpath/bwdown"
    fi
    old_upstr=$up_str
    old_downstr=$down_str
    sleep 1
done
