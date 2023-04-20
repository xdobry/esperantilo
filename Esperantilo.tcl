#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# start File for use XotclIDE with version control
# almost all sources (also for XOTclIDE) are loaded from database
# you need installed version control database and imported
# all XOTclIDE sources to use this script
# use intallVC.tcl for it

set sname [info script]
if {$sname==""} {
    # Run interactive for develop purposes
    set progdir [pwd]
} else {
    file lstat $sname stats
    # follow sym links
    if {$stats(type)=="link"} {
	set sname [file readlink $sname]
	if {[file pathtype $sname]=="relative"} {
	    set sname [file join [file dirname [info script]] $sname]
	}
    }
    set progdir [file normalize [file dirname $sname]]
}

if {$progdir==[pwd]} {
    lappend auto_path $progdir
} else {
    lappend auto_path $progdir [pwd]
}

encoding system utf-8
 
package require XOTcl
namespace import ::xotcl::*

if {$tcl_platform(platform) eq "windows"} {
    tcl_endOfWord dummy 0
    set tcl_wordchars \\w
    set tcl_nonwordchars \\W
}

Object IDE
package provide IDECore 1.0

puts "loading EspBazaLingvo"
package require EspBazaLingvo
puts "loading EspSitaksaAnalizo"
package require EspSintaksaAnalizo

EsperantoConf set programoDosierujo $progdir
puts "starting app"
EsperantiloLancxilo lancxuEsperatnilo
