global tcl_platform
if {[string match "Windows*" $tcl_platform(os)]} {
  package ifneeded tcllinkparser 1.0  [list load [file join $dir tcllinkparser.dll]]
} elseif {$tcl_platform(os)=="Linux"} {
  package ifneeded tcllinkparser 1.0  [list load [file join $dir libtcllinkparser1.01.so]]
} else {
  puts "tcllinkparser is not supported"
}
