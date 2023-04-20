global tcl_platform
if {[string match "Windows*" $tcl_platform(os)]} {
  package ifneeded xotcl::hunspell 1.0  [list load [file join $dir xotclhunspell.dll]]
} elseif {$tcl_platform(os)=="Linux"} {
  package ifneeded xotcl::hunspell 1.0  [list load [file join $dir libxotclhunspell1.0.so]]
} else {
  puts "hunspelltcl is not supported"
}


