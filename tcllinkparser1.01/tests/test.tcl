#!/usr/bin/tcl

if {[file exists libload.tcl]} {
    source libload.tcl
} else {
    source [file join [file dirname [info script]] libload.tcl]
}

cd unix

linkparser::init
puts [linkparser::parse "The parser works well"]
linkparser::close
