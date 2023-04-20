global tcl_platform
if {[string match "Windows*" $tcl_platform(os)]} {
  package ifneeded fsatcl 1.00 [list load [file join $dir fsatcl.dll]]
} elseif {$tcl_platform(os)=="Linux"} {
  package ifneeded fsatcl 1.00 [list load [file join $dir libfsatcl1.00.so]]
} else {
  puts "fsatcl is not supported for this platform"
}



