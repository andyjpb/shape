#!/bin/sh

# dragger.tcl ---
#
#	Quick demo using the shape library to provide a coloured cursor
#
# Copyright (c) 1997 by Donal K. Fellows
#
# The author hereby grants permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
#
# IN NO EVENT SHALL THE AUTHOR OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE AUTHOR AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHOR AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
#
# $Id: demo.tcl,v 1.1 1997/09/17 21:10:23 donal Exp donal $

# Now we make cunning use of the backslash/shell trick \
[ -x `dirname $0`/../shapewish ] && exec `dirname $0`/../shapewish $0 ${1+"$@"} || exec wish $0 ${1+"$@"} || { echo "`basename $0`: couldn't start wish" >&2 ; exit 1; }

set dir [file join [pwd] [file dirname [info script]] .]
package ifneeded Shape 0.4 "package require Tk 8\n\
        [list tclPkgSetup "$dir/../unix/" Shape 0.4 {{libshape04.so.1.0 load shape}}]"
lappend auto_path [file join $dir ..]
package require Shape

set images [file join $dir images]

set none [list @[file join $images none.cur] blue]

image create photo redptr   -file [file join $images ptr-red.gif]
image create photo greenptr -file [file join $images ptr-green.gif]
image create photo doc      -file [file join $images doc-img.gif]
set ptrxbm @[file join $images ptr-mask.xbm]
set docxbm @[file join $images doc-mask.xbm]

pack [label .l -justify l -text "Drag off this window to see a coloured\
	cursor\n(implemented using a canvas and the non-rectangular\nwindow\
	extension) in action.\n\nNow it is your turn to take this away and\
	build a full\ndrag-and-drop system around this.\n\nOther things you\
	could try include animated cursors,\nXEyes and OClock clones, etc."]

toplevel .cursor
wm withdraw .cursor
wm overrideredirect .cursor 1
pack [canvas .cursor.workarea -bd 0 -highlightthick 0]
set image(status) [.cursor.workarea create image 0 0 \
	-anchor nw -image greenptr]
set image(doc) [.cursor.workarea create image 3 4 \
	-anchor nw -image doc]
#pack [label .cursor.ptr -bd 0 -image greenptr]
update idletasks
shape set .cursor.workarea -offset 0 0  bitmap $ptrxbm
shape upd .cursor.workarea + -offset 3 4  bitmap $docxbm
shape set .cursor  window .cursor.workarea

proc movecursor {x y} {
    global image
    wm geometry .cursor +$x+$y
    update idletasks
    set w [winfo containing $x $y]
    if {[string length $w] && [winfo toplevel $w] == "."} {
	.cursor.workarea itemconf $image(status) -image greenptr
    } else {
	.cursor.workarea itemconf $image(status) -image redptr
    }
}
proc showcursor {w x y} {
    global savedcursor none
    set savedcursor [list $w conf -cursor [$w cget -cursor]]
    $w conf -cursor $none
    movecursor $x $y
    wm deiconify .cursor
    raise .cursor
    after 250 raisewin .cursor
}
proc raisewin w {
    if {[winfo exists $w] && [winfo ismapped $w]} {
	raise $w
	after 250 raisewin $w
    }
}
	
proc hidecursor {} {
    global savedcursor
    wm withdraw .cursor
    eval $savedcursor
}

bind . <1> {showcursor %W %X %Y}
bind . <B1-Motion> {movecursor %X %Y}
bind . <ButtonRelease-1> {hidecursor}
