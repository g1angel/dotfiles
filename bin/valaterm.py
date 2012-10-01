#!/usr/bin/env python
# -*- coding: UTF8 -*-
#
# A program to run valaterm with the colors from Xresources.
# Copyright (C) 2010 Josiah Gordon <josiahg@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


""" A program to run valaterm with the colors from Xresources

"""

import re
from shlex import split as splitargs
from os import getenv
from os.path import isfile
from subprocess import Popen
from argparse import ArgumentParser
#from optparse import OptionParser


def run_valaterm(font, opacity, args=None):
    """ run_valaterm(font, opacity) ->
    Grab the colors from $HOME/.Xresources and use the font and opacity
    arguments to run valaterm.

    """

    filename = None
    for name in ['.Xresources', '.Xdefaults']:
        filename = '%s/%s' % (getenv('HOME'), name)
        if isfile(filename):
            break

    check = re.compile(r'[ ]*\*color([0-9]*):[ ]*(#[A-Za-z0-9]*)')
    bgfg_check = re.compile(r'\*(fore|back)ground:[ ]*(#[A-Za-z0-9]*)')
    palette = [None] * 16
    arg_list = ['--font=%s' % font, '--opacity=%s' % opacity]

    if filename:
        with open(filename) as xresources:
            for line in xresources:
                match = check.match(line)
                if match:
                    group = match.groups()
                    palette[int(group[0])] = group[1]
                else:
                    bgfg_match = bgfg_check.match(line)
                    if bgfg_match:
                        arg_str = '--%scolor=%s' % bgfg_match.groups()
                        arg_list.append(arg_str)
        arg_list.append('--palette=%s' % ':'.join(palette))

    if args:
        arg_list.extend(splitargs(args))
    cmd_list = ['valaterm']
    cmd_list.extend(arg_list)

    Popen(cmd_list)

#run_valaterm('droid sans mono 11', 0.85)
if __name__ == "__main__":

    parser = ArgumentParser(description="A wrapper for valaterm")
    parser.add_argument('-f', '--font', action='store',
                        default='Droid Sans Mono 11',
                        help='Font to use', dest='font')
    parser.add_argument('-o', '--opacity', action='store',
                        default=1.00, type=int,
                        help='Opacity of the background', dest='opacity')

    parsed_args = parser.parse_args()
    run_valaterm(parsed_args.font, parsed_args.opacity)
    #print(args.font)

    #parser = OptionParser(description="A wrapper for valaterm")
    #parser.add_option('-f', '--font', action='store',
                        #default='Droid Sans Mono 11',
                        #help='Font to use', dest='font')
    #parser.add_option('-o', '--opacity', action='store',
                        #default=0.85, type=float,
                        #help='Opacity of the background', dest='opacity')

    #options, args = parser.parse_args()
    #run_valaterm(options.font, options.opacity)
