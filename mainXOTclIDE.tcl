package require starkit
if {[starkit::startup] ne "sourced"} {
   lappend auto_path [file join $::starkit::topdir lib xotcl1.5.2 comm]
   package require XOTclIDE
   IDEStarter startFromMenu 1
}
