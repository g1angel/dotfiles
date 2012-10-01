# bashrc terminal color setup

if [[ $TERM =~ "xterm" ]]; then
    export TERM="xterm-256color"
elif [[ $TERM =~ "linux" ]]; then
    # Set console palette
    if [[ -f $HOME/.Xresources ]]; then
        F_NAME=$HOME/.Xresources
    elif [[ -f $HOME/.Xdefaults ]]; then
        F_NAME=$HOME/.Xdefaults
    fi
    if [[ -n $F_NAME ]]; then
        gawk '
            /^[[:space:]]*\*color/ {
                num = gensub(/\*color([[:digit:]]*):/, "\\1", "g", $1)
                color = gensub(/^#([[:alnum:]]*)/, "\\1", "g", $2)
                printf "\033]P%x%s", num, color
            }' "${F_NAME}"
        echo -en "\e]P03b3b3b"
        echo -en "\e]P85d5d5d"
    else
        # Black
        #echo -en "\e]P0292929"
        #echo -en "\e]P84d4d4d"
        echo -en "\e]P03b3b3b"
        echo -en "\e]P85d5d5d"
        # Red          ------
        echo -en "\e]P1DE6951"
        echo -en "\e]P9c56a47"
        # Green        ------
        echo -en "\e]P2bcda55"
        echo -en "\e]PA9dbf60"
        # Yellow       ------
        echo -en "\e]P3E2A564"
        echo -en "\e]PBEC8A25"
        # Blue         ------
        echo -en "\e]P42187F6"
        echo -en "\e]PC5495DC"
        # Magenta      ------
        echo -en "\e]P5875C8D"
        echo -en "\e]PDE41F66"
        # Cyan         ------
        echo -en "\e]P64390B1"
        echo -en "\e]PE276CC2"
        # White        ------
        echo -en "\e]P7D2D2D2"
        echo -en "\e]PFffffff"
    fi
    #clear
fi

# Setup dir colors
if [[ -e "$HOME/.dir_colors.$TERM" ]]
then
    export COLORS=$HOME/.dir_colors.$TERM
else
    export COLORS=$HOME/.dir_colors
fi
eval `dircolors -b $COLORS`

# Setup grep colors
if [[ $(tput colors) -eq 256 ]]
then
    export GREP_COLOR="01;38;5;81"
else
    export GREP_COLOR="1;34"
fi

# Set less color scheme.
export LESS_TERMCAP_mb=$'\E[00;34m'
export LESS_TERMCAP_md=$'\E[01;34m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

