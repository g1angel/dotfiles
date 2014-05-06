# bashrc functions

# command_exists: Function to check if a command exists. #{{{
# If the command exists, return 0, otherwise return 1.
function command_exists()
{
    local cmd=$1
    if [ -n "$(hash $cmd 2>&1)" ]
    then
        return 1
    fi
    return 0
} #}}}

# setup_colors: Setup the terminal colors, and common tools color schemes.#{{{
function setup_colors()
{
    # bashrc terminal color setup

    # Initialize local variables
    local F_NAME=

    # Setup the terminal colors {{{
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
            # echo -en "\e]P0202326"
            # echo -en "\e]P8cccccc"
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
    # }}}

    # Setup dir colors {{{
    if [[ -e "$HOME/.dir_colors.$TERM" ]]
    then
        export COLORS=$HOME/.dir_colors.$TERM
    else
        export COLORS=$HOME/.dir_colors
    fi
    eval `dircolors -b $COLORS`
    # }}}

    # Setup grep colors {{{
    if [[ $(tput colors) -eq 256 ]]
    then
        export GREP_COLOR="01;38;5;81"
    else
        export GREP_COLOR="1;34"
    fi
    # }}}

    # Set less color scheme. {{{
    export LESS_TERMCAP_mb=$'\E[00;34m'
    export LESS_TERMCAP_md=$'\E[01;34m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;33m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[01;32m'
    # }}}
} #}}}

# Filename related functions.#{{{
# lcase: Bash lowercase a list of files.#{{{
function lcase()
{
    for i in "$@"
    do
        mv "$i" "${i,,}"
    done
} #}}}
# ucase: Bash uppercase a list of files.#{{{
function ucase()
{
    for i in "$@"
    do 
        mv "$i" "${i^^}"
    done
} #}}}
# remspace: Bash remove spaces in a list of files.#{{{
function remspace()
{
    for i in "$@"
    do 
        mv "$i" "$(echo "$i"|sed -e 's/[[:blank:]]/_/g')"
    done
} #}}}

# rwith: Bash replace with function.#{{{
function rwith()
{
    if (($#<3))
    then
        printf "usage rwith <pattern> <replacement> <files>\n"
        printf "replaces files with pattern replaced with replacement\n"
    else
        pattern=$1
        rep=$2
        shift 2
        for i in "$@"
        do
            mv "$i" "$(echo "$i"|sed 's/'"$pattern"'/'"$rep"'/g')" 2>/dev/null
        done
    fi
} #}}}

# tolower: Sed lowercase a list of files.#{{{
function tolower
{
    if (($#<1))
    then
        printf "usage: tolower <path> <pattern>\n"
        printf "Recursively renames all files that match <pattern> in <path>\n"
        printf "to their lowercase equivalent.\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n"
    else
        if (($#<2))
        then
            pat="*"
        else
            pat=$2
        fi
        find "$1" -name "$pat" -type f | sed -n '
                /[[:upper:]]/ {     # if <path> has uppercase letters in it
                    s/.*/mv "&"/g   # replace all with mv "all" (pattern space
                                    # = mv "<path>")
                    h               # copy pattern space to hold space (hold
                                    # space = pattern space)
                    s/^mv //g       # replace "mv " at start of line with ""
                                    # (pattern space = "<path>")
                    s/[^\/]*$/\L&/g # uppercase last filename (pattern space =
                                    # "<path lowercase last filename>")
                    H               # append pattern space to hold space (hold
                                    # space = mv "<path>"\n"<path lowercase
                                    # last filename>")
                    x               # swap pattern and hold spaces
                    s/\n/ /gp       # replace newline characters with a space
                                    # (pattern space = mv "<path>" "<path
                                    # lowercase last filename>")
                }'|sh
    fi
} #}}}

# toupper: Sed uppercase a list of files.#{{{
function toupper
{
    if (($#<1))
    then
        printf "usage: toupper <path> <pattern>\n"
        printf "Recursively renames all files that match <pattern> in <path>\n"
        printf "to their uppercase equivalent.\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n"
    else
        if (($#<2))
        then
            pat="*"
        else
            pat=$2
        fi
        find "$1" -name "$pat" -type f | sed -n '
                /[[:lower:]]/ {     # if <path> has lowercase letters in it
                    s/.*/mv "&"/g   # replace all with mv "all" (pattern space
                                    # = mv "<path>")
                    h               # copy pattern space to hold space (hold
                                    # space = pattern space)
                    s/^mv //g       # replace "mv " at start of line with ""
                                    # (pattern space = "<path>")
                    s/[^\/]*$/\U&/g # uppercase last filename (pattern space =
                                    # "<path uppercase last filename>")
                    H               # append pattern space to hold space (hold
                                    # space = mv "<path>"\n"<path uppercase
                                    # last filename>")
                    x               # swap pattern and hold spaces
                    s/\n/ /gp       # replace newline characters with a space
                                    # (pattern space = mv "<path>" "<path
                                    # uppercase last filename>")
                }'|sh
    fi
} #}}}

# repwith: Sed replace with function.#{{{
function repwith
{
    if (($#<3))
    then
        printf "usage: repwith <path> <string> <replacement> <pattern>\n\n"
        printf "Recursively replaces <string> in files that match\n"
        printf "<pattern> in <path> with <replacement>\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n"
    else
        if (($#<4))
        then
            pat="*"
        else
            pat=$4
        fi
# old        find "$1" -type f | sed -n '/'"$2"'/ { s/\([\.\/[:alnum:]]*\)'"$2"'\([\.\/[:alnum:]]*\)/mv "\1'"$2"'\2" "\1'"$3"'\2"/gp }' | sh
        ss=$(echo "$2"|sed 's/\"//g')   # remove quotes from search string
        rs=$(echo "$3"|sed 's/\"//g')   # remove quotes from replacement string
        find "$1" -xdev -name "$pat"|sed -n '
                s/.*/mv "&"/    # replace all with mv "all" (pattern space = mv
                                # "<path>")
                h               # copy pattern space into hold space
                s/^mv //        # remove "mv " from the start of pattern space
                                # (pattern space = "<path>")
                s/\(^[[:print:]]*\)\/\([^\/]*$\)/ \1\//g    # remove from the
                                                            # last "/" to the
                                                            # end (pattern
                                                            # space = "<path>"
                                                            # - last filename)
                H               # append pattern space to hold space (hold
                                # space = mv "<path>" "<path> - last filename")
                g               # copy hold space to pattern space (pattern
                                # space = hold space)
                s/\(^[[:print:]]*\)\/\([^\/]*\n "\)/\2/g    # remove from start
                                                            # to last "/" of
                                                            # first line
                                                            # (pattern space =
                                                            # last filename"\n
                                                            # "<path> - last
                                                            # filename)
                s/\n[[:print:]]*$//g    # remove all but the first line
                                        # (pattern space = last filename")
                /'"$ss"'/ {      # if it has string in it
                    s/'"$ss"'/'"$rs"'/g   # replace all string with replacement
                                          # (last filename" = replace last
                                          # filename")
                    H           # append pattern space to hold space (hold
                                # space = mv "<path>"\n "<path>\nreplaced last
                                # filename")
                    x           # swap pattern and hold spaces (pattern space =
                                # hold space)
                    s/\n//g     # remove all newline characters (pattern space
                                # = mv "<path>" "<pathreplaced last filename")
                    p           # print pattern space
                }'|sh
    fi
} #}}}

# tolower_awk: Awk lowercase a list of files.#{{{
function tolower_awk
{
    if (($#<1))
    then
        printf "usage: tolower_awk <path> <pattern>\n\n"
        printf "Recursively renames all files in <path> that match <pattern> to"
        printf "their lowercase\nequivalent.\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n\n"
        printf "This function uses awk\n"
    else
        if (($#<2))
        then
            pat="*"
        else
            pat=$2
        fi
        find "$1" -name "$pat" -type f | awk '
                BEGIN {                 # beginning 
                    FS="/"              # field separator = "/"
                    OFS="/"             # output field separator = "/"
                } 
                $NF ~ /[[:upper:]]/ {   # if last field has uppercase letters
                    oldr=$0             # then backup record
                    $NF=tolower($NF)    # make last field lowercase
                    printf("mv \"%s\" \"%s\"\n", oldr, $0 ) | "sh" # pipe "mv
                                                                   # oldr $0"
                                                                   # to sh
                }
                END {                   # end
                    close("sh")         # close sh
                }'
    fi
} #}}}

# toupper_awk: Awk uppercase a list of files.#{{{
function toupper_awk
{
    if (($#<1))
    then
        printf "usage: toupper_awk <path> <pattern>\n\n"
        printf "Recursively renames all files in <path> that match <pattern>\n"
        printf "to their uppercase equivalent.\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n\n"
        printf "This function uses awk\n"
    else
        if (($#<2))
        then
            pat="*"
        else
            pat=$2
        fi
        find "$1" -name "$pat" -type f | awk '
                BEGIN {
                    FS="/"      # field separator = "/"
                    OFS="/"     # output field separator = "/"
                } 
                $NF ~ /[[:lower:]]/ {   # if last field has lowercase letters
                    oldr=$0             # then backup old record
                    $NF=toupper($NF)    # make last field uppercase
                    printf("mv \"%s\" \"%s\"\n", oldr, $0 ) | "sh" # pipe "mv
                                                                   # oldr $0"
                                                                   # to sh
                }
                END {
                    close("sh")     # close sh pipe
                }'
    fi
} #}}}

# repwith_awk: Awk replace with function.#{{{
function repwith_awk
{ 
    if (($#<3))
    then
        printf "usage: repwith_awk <path> <string> <replacement> <pattern>\n\n"
        printf "Recursively replaces <string> in filenames that match <pattern>\n"
        printf "in <path> with <replacement>\n\n"
        printf "NOTE: Make sure to place double quotes around <pattern>\n\n"
        printf "This function uses awk\n"
    else
        if (($#<4))
        then
            pat="*"
        else
            pat=$4
        fi
# old        find "$1" -type f | sed -n '/'"$2"'/ { s/\([\.\/[:alnum:]]*\)'"$2"'\([\.\/[:alnum:]]*\)/mv "\1'"$2"'\2" "\1'"$3"'\2"/gp }' | sh
        ss=$(echo "$2"|sed 's/\"//g')   # remove quotes from search string
        rs=$(echo "$3"|sed 's/\"//g')   # remove quotes from replacement string
        find "$1" -xdev -name "$pat" | awk '
                BEGIN {
                    FS="/"      # field separator = "/"
                    OFS="/"     # output field separator = "/"
                } 
                $NF ~ /'"$ss"'/ {   # if last field has search pattern
                    oldr=$0         # backup old record
                    gsub(/'"$ss"'/, "'"$rs"'", $NF) # replace search pattern
                                                    # with replacement in last
                                                    # field
                    printf("mv \"%s\" \"%s\"\n", oldr, $0 ) | "sh" # pipe "mv
                                                                   # oldr $0" to sh
                }
                END {
                    close("sh") # close sh pipe
                }'
    fi
} #}}}
#}}}

# lsd: List only directories.#{{{
function lsd () {
    if [ $# -gt 0 ]; then
        for i in $@ ;
        do
            ls --color -d "$i/"*/;
        done;
    else 
        ls --color -d */;
    fi
} #}}}

# set_title: Set the title for terminals that use it.#{{{
function set_title ()
{
	eval $BASH_COMMAND
	echo -ne "\e]0;$USER@$HOSTNAME:${PWD/#$HOME/~}\a"
	return 1
} #}}}

# 7zless: Less 7zip files #{{{
function 7zless {
    7z l "$1" | less
} #}}}

# playsc68: Play sc68 files through aplay.#{{{
#function playsc68 {
#    sc68 "$1" | aplay -t raw -c 2 -r 44100 -f S16
#} #}}}

# macrobber: Macrobber fix#{{{
#function macrobber ()
#{
    #mac-robber "$1" | sed -e '/^0/ { s/[^|]*|//3; s/[^|]*|//4;s/[^|]*|//5;s/[^|]*|//7}'
#} #}}}

# pacs: colorized pacman output.#{{{
function pacs() {
    local CL='\\e['
    local RS='\\e[0m'

    echo -e "$(pacman -Ss "$@" | sed "
        /^core/     s,.*,${CL}1;31m&${RS},
        /^extra/    s,.*,${CL}0;32m&${RS},
        /^community/    s,.*,${CL}1;35m&${RS},
        /^[^[:space:]]/ s,.*,${CL}0;36m&${RS},
    ")"
} #}}}

#alias pacs="pacsearch"#{{{
#function pacsearch() {
   #echo -e "$(pacman -Ss "$@" | sed \
     #-e 's#^core/.*#\\033[1;31m&\\033[0;37m#g' \
     #-e 's#^extra/.*#\\033[0;32m&\\033[0;37m#g' \
     #-e 's#^community/.*#\\033[1;35m&\\033[0;37m#g' \
     #-e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g' ) \
     #\033[0m"
#} #}}}

# lesspkg function and completion.#{{{
# Colorize a packages contents#{{{
function lesspkg ()
{
    # Initialize local variables
    local pkgman_cmd=
    local pkg_list=

    pkgman_cmd="pacman"
    pkg_list=$($pkgman_cmd -Ql "$1" 2>/dev/null)
    if [[ -n $pkg_list ]]
    then
        # Colorize the output (very slow)
        #pkg_list=${pkg_list//$1 /"\e[1;34m$1 \e[0m"}

        # Using sed to colorize is way faster!
        printf "${pkg_list}" | sed '
            # Color the package name
            s/'"$1 "'/[1;35m'"$1 "'[0m/g
            # Color gzs
            s|\(.*/\)\(.*\.gz\)$|\1[1;31m\2[0m|g
            # Color files in a *bin/ directory
            s|\(.*\)bin/\(.*\)|\1bin/[1;32m\2[0m|g
            # Color directory names
            s|/\(.*\)/|[1;34m/\1/[0m|g
            ' | less
    else
        printf "No output.\nMaybe ${1} is not installed.\n"
    fi
} #}}}

# Completion function for lesspkg.#{{{
function _lesspkg()
{
    # Make cur the currently typed argument.
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Assign a list of the installed packages minus the version to pkglist.
    local pkglist="$(pacman -Q|cut -d ' ' -f 1)"

    # Set COMPREPLY to the completion matches for the current argument.
    COMPREPLY=($(compgen -W "${pkglist}" -- "$cur"))
} #}}}

# Set the completion function for lesspkg to _lesspkg.
complete -F _lesspkg lesspkg
#}}}

# pacc: Colorized pacman search#{{{
function pacc()
{
    # Initialize local variables
    local pac_prog=

    if [[ $1 == '--aur' ]]
    then
        [[ -n $(which packer) ]] && pac_prog='packer --auronly' || pac_prog='pacman'
        shift 1
    else
        pac_prog='pacman'
    fi
    local CB='\\e['
    local CE='\\e[0m'
    local LB='\([^[:space:]]*\)[[:space:]]\([^[]*\)\(.*\)'
    local LC="/${CB}1m\2${CE} ${CB}1;32m\3${CE}${CB}34m\4${CE}"

    echo -e "$($pac_prog -Ss "$@" | sed "
        /^core/         s|^\(core\)/${LB}|${CB}1;35m\1${CE}${LC}|
        /^extra/        s|^\(extra\)/${LB}|${CB}1;34m\1${CE}${LC}|
        /^community/    s|^\(community\)/${LB}|${CB}1;33m\1${CE}${LC}|
        /^[[:alnum:]]/  s|^\([^/]*\)/${LB}|${CB}1;36m\1${CE}${LC}|
    ")"
} #}}}

# pkgdesc: Print the description of a package.#{{{
function pkgdesc() {
    local CN='\033[1;34m'
    local CD='\033[1m'
    local CC='\033[0m'

    pacman -Qi "$@" | gawk '
        BEGIN {
            FS = ": "
        }
        /^Name/ { 
            name = $2
        }
        /^Description/ {
            description = $2
            printf "'${CN}'%-25s '${CC}'%-2s'${CD}'%s'${CC}'\n", name, ":", description
        }'
} 

# Set the completion function fo pkgdesc to _lesspkg.
complete -F _lesspkg pkgdesc
#}}}

# lspkgs: List all packages with there description.#{{{
function lspkgs() 
{
    pkgdesc | less
} #}}}

# gcore and its completion function.#{{{
# gcore: Dump core of processes.#{{{
function gcore() 
{
    # Fail if gdb is not found.
    command_exists "gdb" || { echo "Error: gdb not found."; return 1; }

    # Initialize local variables
    local pid_num=
    local proc=
    local process_name=

    # Loop through the arguments.
    for proc in "$@"
    do
        # Extract the pid from the process line.
        pid_num=${proc%%[[:space:]]*}

        # Remove the pid from the front of the process line.
        process_name="${proc#$pid_num[[:space:]]*}"

        printf "Dumping core for process: \"%s\"\n" "$process_name"

        # Use gdb to dump core for a running process
        gdb --pid=$pid_num --batch -ex gcore
    done

    echo "Done."
} #}}}

# _gcore: Completion function for gcore.#{{{
function _gcore()
{
    # Grab the currently being typed argument.
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Put the output of ps into complist after removing leading spaces and
    # replacing the rest of the spaces with '_'s.
    #mapfile -t complist < <(ps -u $USER -o pid= -o command= | sed -e 's/^[[:space:]]*//' -e "s/'/'\\\\\\'\\\\\\\\\\\'\\\\\\''/g" -e 's/\(^\|$\)/'"'"'/g' -e '/sdfasdfasdf/d')

    # Put the output of ps into complist after removing leading spaces and
    # replacing the rest of the spaces with '_'s.
    mapfile -t complist < <(ps -u $USER -o pid= -o command= | sed \
        ""'s/^[[:space:]]*//'"      # Strip leading spaces from each line.
         /asdfadsfadsfadsf/d	    # Delete the sed program from the list.
         s/'/'\\\\\\'\\\\\\\\\\\'\\\\\\''/g     # Escape all single quotes.
         "'s/\(^\|$\)/'"'"'/g'"     # Surround each line by single quotes.
         ")   

    # Uncomment for testing purpasses.
    #printf "\n%s" "${complist[@]}"
    #return

    # Populate the COMPREPLY array.
    old_ifs=$IFS
    IFS=$'\n' COMPREPLY=($(IFS=$old_ifs compgen -W "${complist[*]}" -- "$cur"))
    IFS=$old_ifs

    # Uncomment for testing purpasses.
    #printf "%s\n" "${COMPREPLY[@]}"
    #return

    # Loop to fix spaces in lines.
    #local i=0
    #for comp in ${COMPREPLY[@]}
    #do
        #if [[ "${cur:0:1}" == "'" || "${cur:0:1}" == '"' ]]
        #then
            ## If the start of the current argument is a quote than replace all
            ## '_'s with a space.
            #COMPREPLY[$i]="${comp//_/ }"
        #else
            ## Replace all '_'s with an escaped space.
            #COMPREPLY[$i]="${comp//_/\\ }"
        #fi
        #(( i++ ))
    #done
} #}}}

# Set the completion function for gcore to _gcore and prefix and suffix every
# completed argument with single quotes.
complete -P "'" -S "'" -F _gcore gcore
#}}}

# tovorbis: Function to convert media files to ogg vorbis audio.#{{{
function tovorbis() {
    command_exists "ffmpeg" || { echo "Error: ffmpeg not found."; return 1; }

    # Initialize variables
    local audio_line=
    local audio_line_length=
    local audio_bitrate=
    local filename=
    local FFMPEG=

    if [[ $1 == '-h' ]]
    then
        echo "Convert a media file to ogg vorbis audio."
        echo "usage: tovorbis filename"
        return 0
    fi

    FFMPEG="$(which ffmpeg)"

    audio_line=($($FFMPEG -i "$1" 2>&1|grep Audio))
    audio_line_length=${#audio_line[@]}

    if [[ -n $2 ]]
    then
        audio_bitrate=$2
    else
        audio_bitrate=${audio_line[audio_line_length-2]}
    fi

    filename="${1##*/}"
    filename="${filename%.*}.ogg"

    echo "Converting ${i} to ${filename}"
    $FFMPEG -i "$1" -acodec libvorbis -ab "${audio_bitrate}k" -vn \
        -map_metadata 0:s:0 "${filename}"
} #}}}

# ltovorbis: Convert a list of media files to ogg vorbis.#{{{
function ltovorbis() {
    local oifs=$IFS
    IFS=','
    for i in $@
    do
        IFS=$oifs
        tovorbis "$i"
        IFS=','
    done
    IFS=$oifs
} #}}}

# spellw: Spellcheck a word.#{{{
function spellw() {
    echo "$1" | aspell -a
} #}}}

# define: Define a word using dict.org.#{{{
function define() {
    if [[ $1 == '-ls' ]]
    then
        {
            echo -e "SHOW DB\nquit" >&0
            cat <&0
        } < /dev/tcp/dict.org/2628
        return
    fi

    if [[ $# < 2 ]]
    then
        local dict=all
        local word=$1
    else
        local dict=$1
        local word=$2
    fi
    #exec 4<>/dev/tcp/dict.org/2628
    {
        echo -e "DEFINE ${dict} ${word}\nquit" >&0
        cat <&0
    } < /dev/tcp/dict.org/2628
    #exec 4<&-
    #exec 4>&-
} #}}}

# sshtunnel and its completion function.#{{{
# sshtunnel: Create an ssh tunnel to the given machine.#{{{
function sshtunnel()
{
    local RPORT=22
    local LPORT=9050
    ssh -p $RPORT -D $LPORT -f -C -q -N "$@"
    echo "ssh tunnel started on port $LPORT"
} #}}}

# _sshtunnel: Tab completion function for sshtunnel.#{{{
function _sshtunnel()
{
    # Grab the current argument.
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Get the hostname currently being typed.
    h_name=${cur##*@}

    # Get the username typed.
    u_name=${cur%%@*}

    # Generate completions for the hostname.
    COMPREPLY=($(compgen -A hostname -- "$h_name"))

    # Prefix every completion with the username@
    # Reference: ssh bash-completion script
    COMPREPLY=( "${COMPREPLY[@]/#/$u_name@}" )
} #}}}
complete -F _sshtunnel sshtunnel
#}}}

# encrypt: Encrypt files with openssl.#{{{
function encrypt()
{
    command_exists "openssl" || { echo "Error: openssl not found."; return 1; }
    if [ $# -lt 1 ]
    then
        echo "Usage encrypt file-to-encrypt"
    else
        openssl enc -e -aes-256-cbc -in "$1" -out "$1".enc
    fi
} #}}}

# decrypt: Decrypt files with openssl.#{{{
function decrypt()
{
    command_exists "openssl" || { echo "Error: openssl not found."; return 1; }
    if [ $# -lt 1 ]
    then
        echo "Usage decrypt file-to-decrypt"
    else
        openssl enc -d -aes-256-cbc -in "$1" -out "$2"
    fi
} #}}}

# init_virtualenvwrapper: Virtualenvwrapper setup.#{{{
function init_virtualenvwrapper()
{
    command_exists "virtualenvwrapper.sh" || {
        echo "No virtualenvwrapper.sh found."
        return 1
    }

    local WRAPPER_SCRIPT="$(which virtualenvwrapper.sh 2>/dev/null)"
    WORKON_HOME=/mnt/stuff/virtualenvs
    PROJECT_HOME=/mnt/stuff/pyprojects
    [ -d $WORKON_HOME ] && export WORKON_HOME
    [ -d $PROJECT_HOME ] && export PROJECT_HOME
    source $WRAPPER_SCRIPT
} #}}}

# which: A which wrapper that shows functions and aliases.#{{{
function which ()
{
    (alias; declare -f) | /usr/bin/which --tty-only --read-alias \
        --read-functions --show-tilde --show-dot $@
}
complete -f -a -c which

export -f which
#}}}

# killit and its completion function.#{{{
# killit: Kill processes.#{{{
function killit ()
{
    # Fail if no kill command if found.
    local kill_cmd=$(/usr/bin/which --skip-function kill 2>/dev/null)
    [[ -z $kill_cmd ]] && echo "No kill command found." && return 1

    printf "\n"

    # Default signal is 'SIGTERM'.
    local signal="SIGTERM"

    # Initialize other variables
    local proc=
    local process_name=
    local pid_num=

    # Setup output colors.
    local txt_color="\e[1m"
    local proc_color="\e[0;36m"
    local sig_color="\e[0;31m"
    local end_color="\e[0m"

    # Loop through the arguments.
    for proc in "$@"
    do
        # Exit when the end is reached.
        [[ -z "$1" ]] && break

        # Check for options.
        case $1 in
            '-s')
                # A Signal is comming next
                signal=$2
                shift 2
                ;;
            *)
                # Reset signal.
                signal="SIGTERM"
                ;;
        esac

        proc="$1"
        shift

        # Extract the pid from the process line.
        pid_num=${proc%%[[:space:]]*}

        # Remove the pid from the front of the process line.
        process_name="${proc#$pid_num[[:space:]]*}"

        printf "${txt_color}Killing process${end_color}: \"${proc_color}%s${end_color}\" ${txt_color}with signal${end_color} ${sig_color}%s${end_color}\n" "$process_name" $signal

        # Kill process with signal.
        $kill_cmd -s $signal $pid_num
    done

    printf "\nDone.\n"
} #}}}

# _killit: Completion function for killit.#{{{
function _killit()
{
    # Grab the currently being typed argument.
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    local options='-s'

    if [[ $cur == '-' ]]
    then
        COMPREPLY=($(compgen -W "${options}" -- "$cur"))
        return 0
    fi

    if [[ $prev == '-s' ]]
    then
        COMPREPLY=($(compgen -A signal -- "$cur"))
        return 0
    fi

    # Put the output of ps into complist after removing leading spaces and
    # replacing the rest of the spaces with '_'s.
    mapfile -t complist < <(ps -u $USER -o pid= -o command= | sed \
        ""'s/^[[:space:]]*//'"      # Strip leading spaces from each line.
         /asdfadsfadsfadsf/d	    # Delete the sed program from the list.
         s/'/'\\\\\\'\\\\\\\\\\\'\\\\\\''/g     # Escape all single quotes.
         "'s/\(^\|$\)/'"'"'/g'"     # Surround each line by single quotes.
         ")   

    # Populate the COMPREPLY array.
    local old_ifs=$IFS
    IFS=$'\n' COMPREPLY=($(IFS=$old_ifs compgen -P "'" -S "'" -W "${complist[*]}" -- "$cur"))
    IFS=$old_ifs
} #}}}

# Set the completion function for kill to _killit.
complete -F _killit killit
export -f killit
#}}}

# cp437: Run a program with the ibm-cp437 output. {{{
function cp437()
{
    if [[ -n $TMUX ]]
    then
        # When in tmux we can't use unicode_stop
        filterm ascii-ascii cp437-utf8 "${@}"
    else
        # Unicode needs to stop so we can use the ansi characters instead.
        unicode_stop
        # Need to set a font that has all the cp437 characters.
        setfont ter-i20b
        "${@}"
        unicode_start
    fi
}
# Complete executables in PATH
complete -cf cp437
# }}}

# xdg_default: Set the default mime hander for a filetype. {{{
function xdg_default()
{
    # First check if xdg-mime is in the path.
    command_exists "xdg-mime" || { echo "Error: xdg-mime not found."; return 1; }

    # Set the local variables.
    local filename=
    local app=
    local mime=
    local mime_line=
    local arg=

    # Usage message.
    local usage="Usage: xdg_default <-m mime-type|-f file-to-open> -a handler.desktop"

    # Loop through the arguments.
    for arg in "$@"
    do
        # Exit when the end is reached.
        [[ -z "$1" ]] && break

        # Check for options.
        case $1 in
            '-m')
                # Set the mime-type
                mime="${2}"
                shift 2
                ;;
            '-f')
                # Set the file to get the mime-type from
                filename="${2}"
                shift 2
                ;;
            '-a')
                # Set what app will open the mime-type
                app="${2}"
                shift 2
                ;;
            *)
                # Give the usage message and exit.
                printf "${usage}\n"
                return 0
                ;;
        esac
    done

    # Give the usage message if not enought arguments were given
    if [[ (-z $filename && -z $mime) || -z $app ]] 
    then
        printf "${usage}\n"
        return 0
    fi

    if [[ -z $mime ]]
    then
        # Get the mime-type.
        mime_line=$(xdg-mime query filetype "${filename}")

        # An error occured if mime_line is empty
        [[ -z $mime_line ]] && return 1

        # Extract the mime-type from xdg-mime output.
        mime=$(sed -e 's/\([^;]*\);.*$/\1/' <<< "${mime_line}")
    fi

    printf "\e[1mSetting default application for\e[m \e[32m'%s'\e[m to \e[36m'%s'\e[m...\n" $mime $app

    # Create the necessary directory to avoid an error.
    if [[ ! -d $XDG_DATA_HOME/applications ]]
    then
        mkdir -p $XDG_DATA_HOME/applications
    fi

    # Set the default application.
    xdg-mime default "${app}" "${mime}"
} # }}}

# vim: fdm=marker:fdl=0:fmr={{{,}}}
