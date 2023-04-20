# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

global tcl_platform
if {[string match "Windows*" $tcl_platform(os)]} {
    package ifneeded tclsqlite 3.5.5 [load [file join $dir tclsqlite3.dll]]
} elseif {$tcl_platform(os) eq "Linux"} {
    package ifneeded tclsqlite 3.5.5 [load [file join $dir tclsqlite-3.5.5.so]]
} else {
    puts "sqlite is not supported"
}

