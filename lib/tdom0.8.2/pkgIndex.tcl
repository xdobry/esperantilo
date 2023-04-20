global tcl_platform
if {[string match "Windows*" $tcl_platform(os)]} {
  package ifneeded tdom 0.8.2 [list load [file join $dir Windows-x86 tdom.dll]]
} elseif {$tcl_platform(os)=="Linux"} {
  package ifneeded tdom 0.8.2 [list load [file join $dir Linux-x86 tdom.so]]
} else {
  puts "tdom is not supported for this platform"
}
