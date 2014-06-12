#!/bin/bash
# A simple shell script wrapper to record current terminal session of a linux
# desktop. May work under other Unix like operating systems too.
# Tested on RHEL 6.x, Debian 6.x, and Ubuntu Linux
# ----------------------------------------------------------------------------
# Written by Vivek Gite <http://www.cyberciti.biz/>
# (c) 2012 nixCraft under GNU GPL v2.0+
# ----------------------------------------------------------------------------
# Last updated: 19/Aug/2012
# ----------------------------------------------------------------------------
 
_xw=/usr/bin/xwininfo
_recd=/usr/bin/recordmydesktop
_awk=/usr/bin/awk
_grep=/bin/grep
_file="$1"
_output=""
 
# change this to match your PS1 settings
_regex='vivek@wks01: '
 
die(){
echo -e "$1"
exit ${2:9999}
}
 
[ $# -eq 0 ] && die "Usage: $0 filename.ogv\n\nRecord terminal desktop sessions under Linux or Unix." 1
 
 
# add extension .ogv if not given
_ext="${_file%%.ogv}"
[[ "$_ext" == "$_file" ]] && _output="$_file.ogv" || _output="$_file"
 
[ ! -x "$_xw" ] && die "Error: $_xw not found or set correct \$_xw in $0" 2
[ ! -x "$_recd" ] && die "Error: $_recd not found or set correct \$_recd in $0" 3
[ ! -x "$_awk" ] && die "Error: $_awk not found or set correct \$_awk in $0" 4
[ ! -x "$_grep" ] && die "Error: $_grep not found or set correct \$_grep in $0" 5
 
#get terminal window id
_id=$($_xw -root -tree | $_grep "$_regex" | $_awk '{ print $1}')
 
#get terminal windows x,y, width, and hight
_x=$($_xw -id $_id | $_grep 'Absolute upper-left X' | $_awk '{ print $4}')
_y=$($_xw -id $_id | $_grep 'Absolute upper-left Y' | $_awk '{ print $4}')
_w=$($_xw -id $_id | $_grep 'Width:' | $_awk '{ print $2}')
_h=$($_xw -id $_id | $_grep 'Height:' | $_awk '{ print $2}')
 
x=$(( $_x + 8 ))
y=$(( $_y + 57 ))
width=$(( $_w -31 ))
height=$(( $_h -62 ))
 
$_recd --no-sound -x $x -y $y --width $width --height $height -o $_output

#How do I use this script?

    #Open a terminal.
  #  Open Tab.
   # Run script as:

    #./script.sh foo.ogv
    #Switch to tab # 1 and run your command.
    #When done switch back to tab #2 and press CTRL + C to save recording to foo.ogv.
    #To run foo.ogv type:

    #gnome-open foo.ogv
    #OR
    #mplayer foo.ogv
