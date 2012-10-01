# Source bashrc if it is readable.
[ -r $HOME/.bashrc ] && . $HOME/.bashrc

# Set the terminal not to blank, powerdown, or powersave if it is a console and
# not in twin.
if [[ $TERM == "linux" && -z $TWDISPLAY ]] 
then
    setterm -blank 0 -powerdown 0 -powersave off
fi

# Load RVM into a shell session *as a function*
[[ -s "/home/josiah/.rvm/scripts/rvm" ]] && source "/home/josiah/.rvm/scripts/rvm"
