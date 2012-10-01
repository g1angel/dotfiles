#!/usr/bin/perl
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

use warnings;
use strict;

sub getargs;

$0 =~ /.*\/(.*valaterm)\.pl/;
my $cmd = $1;
my ($font, $opacity, $command) = getargs();
my @arg_list = ("VTE_CJK_WIDTH=1", $cmd, "--command='${command}'", "--font='${font}'", "--opacity=${opacity}");
my @pal_list = ();
my $color_reg = "^[[:space:]]*\\*color([[:digit:]]*):[[:space:]]*(#[[:alnum:]]*)";
my $fgbg_reg = "^\\*(fore|back)ground:[[:space:]]*(#[[:alnum:]]*)";
my $filename = $ENV{"HOME"} . "/.Xresources";
$filename = $ENV{"HOME"} . "/.Xdefaults" if (not -e $filename);
if (-e $filename) {
    open RES_FILE, $filename or die "Xresources file not found. $!";
    while (my $line = <RES_FILE>) {
        $pal_list[$1] = $2 if ($line =~ /$color_reg/);
        my $arglen = @arg_list;
        $arg_list[$arglen] = "--${1}color=${2}" if ($line =~ /$fgbg_reg/);
    }
    close RES_FILE;
    my $palette = "--palette=" . join ':', @pal_list;
    $arg_list[scalar(@arg_list)] = $palette;
}
system("@arg_list &");

sub getargs {

    # my $font = "Droid Sans Mono 11";
    # my $font = "DejaVu Sans Mono 11";
    my $font = "Ricty 13";
    # my $font = "Inconsolata 13";
    my $opacity = 1; #0.85;
    my $command = '/bin/bash';

    for (my $i = 0; $i <= $#ARGV; $i++)
    {
        die "usage: $0 -o [opacity] -t [font] -e [command]\n" if $ARGV[$i] eq "--help";
        if ($ARGV[$i] eq "-o") {
            $opacity = $ARGV[$i+1];
            $i++;
        } elsif ($ARGV[$i] eq "-t") {
            $font = $ARGV[$i+1];
            $i++;
        } elsif ($ARGV[$i] eq "-e") {
            $command = $ARGV[$i+1];
            $i++;
        }
    }
    $opacity = 1 if $opacity > 1;
    $opacity = 0 if $opacity < 0;

    return ($font, $opacity, $command);
}
