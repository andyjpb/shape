#!/bin/sh

# fancytext.tcl ---
#
#	Make a piece of text look interesting by suggesting the shape of the
#	letters
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

set font {Helvetica 72 bold}
. conf -bg black
pack [canvas .c -bg black -bd 0 -highlightthick 0] -fill both -expand 1
shape set .c text "Some Text" $font
set bb [shape bound .c]
set offmax [lindex $bb 3]
proc moveLine {idx} {
    global count line inc
    .c move $idx 0 $inc($idx)
    incr count($idx) $inc($idx)
}
proc moveFwds {idx} {
    global count offmax delay inc
    if {$count($idx)<$offmax} {
	moveLine $idx
	after $delay($idx) moveFwds $idx
    } else {
	set inc($idx) [expr -$inc($idx)]
	moveBack $idx
    }
}
proc moveBack {idx} {
    global count offmax delay inc bb
    if {$count($idx)>[lindex $bb 1]} {
	moveLine $idx
	after $delay($idx) moveBack $idx
    } else {
	set inc($idx) [expr -$inc($idx)]
	moveFwds $idx
    }
}
proc move {line delayVal incVal} {
    global count delay inc
    set count($line) 0
    set delay($line) $delayVal
    set inc($line) $incVal
    moveFwds $line
}
set width  [expr [lindex $bb 0]+[lindex $bb 2]]
set height [expr [lindex $bb 1]+[lindex $bb 3]]
wm geometry . ${width}x${height}
wm sizefrom . user
update
move [.c create line 0 0 [lindex $bb 2] 0 -fill blue]   50 2
move [.c create line 0 0 [lindex $bb 2] 0 -fill green]  50 3
move [.c create line 0 0 [lindex $bb 2] 0 -fill red]    50 5
move [.c create line 0 0 [lindex $bb 2] 0 -fill yellow] 50 7
