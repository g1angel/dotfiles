'''
File: pythonrc.py
Author: Josiah Gordon
Description: Python configureation file.
'''

try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    # Enable tab completion
    import rlcompleter
    readline.parse_and_bind("tab: complete")

    # Colorize the python prompt.
    import sys
    sys.ps1 = "\001\033[32m\002>>>\001\033[m\002 "
    sys.ps2 = "\001\033[33m\002...\001\033[m\002 "

    # Remember history between sessions.
    import os
    histfile = os.path.join(os.environ["HOME"], ".pyhist")
    try:
        readline.read_history_file(histfile)
    except IOError:
        pass
    import atexit
    atexit.register(readline.write_history_file, histfile)
    del os, histfile
