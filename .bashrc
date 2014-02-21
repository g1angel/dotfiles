# .bashrc

### Initialize #{{{

# Check for an interactive session
[ -z "$PS1" ] && return

# Use the systemwide profile settings.
source /etc/profile

# Make the cursor a solid non-blinking block.
# printf "[?81;0;112c"

# Make the cursor a solid non-blinking inverse block.
# Reference: http://unix.stackexchange.com/questions/3759/how-to-stop-cursor-from-blinking
# printf "[?17;0;127c"

# Make the cursor solid red non-blinking block.
# printf "\e[?16;0;64c"

# Make the cursor blinking.
printf "\e[?8c"

# If we are not in X but we are in tmux set the TERM variable so vim will use
# the correct color scheme.
if [[ -z $DISPLAY && -n $TMUX ]]; then
    export TERM="screen.linux"
    printf "[?17;0;127c"
fi

# A directory for extra bash settings.
BASH_DIR=$HOME/.bashrc.d

# Load user defined functions
source $BASH_DIR/functions.sh

# Only set colors if we're not root.
if [[ $UID != 0 ]]; then
    # Setup the terminal colors
    setup_colors

    # Setup the prompt
    #PS1='[\u@\h \W]\$ '
    PS1='\[\e[0;32m\][\u@\h \W]\$\[\e[0m\] '
    # PS1='\[\e[0;33m\]┌[\[\e[0;32m\]\u@\H \[\e[1;34m\]\w\[\e[0;33m\]]\n└\[\e[0;32m\]\$\[\e[0m\] '
    # PS1='\[\e[0;33m\]┌[\[\e[0;32m\]\u@\H \[\e[1;34m\]\w \[\e[0;36m\]$(__git_ps1 "git (%s)")\[\e[0;33m\]]\n└\[\e[0;32m\]\$\[\e[0m\] '
else
    PS1='\[\e[0;31m\][\u@\h \W]\$\[\e[0m\] '
fi
#}}}

### Set environment variables #{{{

# Set common environment variables.
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim
export PATH=/opt/kde/bin:/usr/lib/ccache/bin:$PATH:$HOME/bin

# Add ruby gems path
export PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin

# Only use utf-8 in X otherwise use C in the console.
if [[ -z $LC_ALL && -n $DISPLAY ]]
then
    # If not already set than set the locale to en_US.UTF-8
    export LC_ALL=en_US.UTF-8
elif [[ -z $DISPLAY ]]
then
    export LC_CTYPE=C
fi

# Export python related variables.
export PYTHONDOCS=/usr/share/doc/python/html/
export PYTHONSTARTUP=$HOME/.pythonrc.py

# Set qt path for themes.
export QT_PLUGIN_PATH=$HOME/.kde4/lib/kde4/plugins/:/usr/lib/kde4/plugins/

# Export default pkg-config path
export PKG_CONFIG_PATH="/usr/lib/pkgconfig"

# Some readline stuff that is fairly common
HISTSIZE=1000
HISTCONTROL="erasedups"

# Set the history timestamp format
HISTTIMEFORMAT='%F %T'

INPUTRC="$HOME/.inputrc"
LESS="-R"

export HISTSIZE HISTCONTROL HISTTIMEFORMAT INPUTRC LESS

# Setup proxy
#export http_proxy=http://127.0.0.1:8118

# Set rsense home
RSENSE_HOME=$HOME/.vim/rsense-0.3
#}}}

### User specific aliases and functions #{{{

if [[ -n $(which grc 2>/dev/null) ]]; then
    # Colorized commands
    alias cping='grc ping'
    alias ctail='grc tail'
fi

# Make spicec not use uim or ibus.
alias spicec='XMODIFIERS=@im= spicec'

# Make grep and ls use colors.
alias grep='grep --color=auto'
alias ls='ls --color=auto'

alias ll="ls -lh"
alias la="ls -a"

# Set rm, cp, and mv to always ask before overwriting or deleting a file, and
# to be verbose.
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# Mplayer aliases for playing movies in the console framebuffer.
alias fbmp='mplayer -really-quiet -vo fbdev2 -fs'
width=$(fbset | sed -n 's/mode "\([[:digit:]]*\)x[[:digit:]]*"/\1/gp')
alias fbmpfs="mplayer -really-quiet -vo fbdev2 -fs -zoom -xy ${width}"

# Dtach aliases for dvtm and bash.
alias ddvtm='dtach -c /tmp/dvtm-session -r winch dvtm'
alias dbash="dtach -c ${HOME}/.bash-session bash"

# A quick way of searching the processes for running applications.
alias psgrep='ps aux|grep -v grep|grep'

alias waei='waei 2>/dev/null'

# Encryption aliases
alias gpge='gpg --armor --sign --encrypt'
alias gpgd='gpg --decrypt'

# Always enable utf-8 in tmux.
alias tmux='tmux -u'

# Use a tmux session called 'x' in X.
alias xtmux='tmux -L x'

#alias htedit='valaterm -e hte'
#alias timidity='timidity -Os -EFreverb=d -EFchorus=d --module=111'

# cdrom aliases
alias blankcd='wodim -v dev=/dev/cdrom -blank=fast'
alias burniso='wodim -v dev=/dev/cdrom'
alias burnaudio='wodim -v -pad speed=1 dev=/dev/cdrom -dao -swab'
alias burnnoswab='wodim -v -pad speed=1 dev=/dev/cdrom -dao'
alias getiso='readcd -v dev=/dev/cdrom -f'
alias clonecd='readom -v dev=/dev/cdrom -clone -nocorr f='
#}}}

### Set shell options {{{
# Make the shell append the history instead of overwriting.
shopt -s histappend
# }}}

### Completion setup #{{{

# complete after man, sudo, etc...
complete -cf sudo
complete -cf man
#}}}

# vim: fdm=marker:fdl=0:fmr={{{,}}}
