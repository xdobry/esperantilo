if {![package vsatisfies [package provide Tcl] 8.4]} {return} ; \
if {[package vsatisfies [package provide Tcl] 8.5]} { \
    package ifneeded dict 8.5 {package provide dict 8.5} ; \
    return \
} ; \
if {[string match "Windows*" $::tcl_platform(os)]} {
  package ifneeded dict 8.5.3 [list load [file join $dir dict853.dll] Dict] 
} elseif {$::tcl_platform(os)=="Linux"} {
  package ifneeded dict 8.5.2 [list load [file join $dir libdict8.5.2.so] Dict] 
} else {
  puts "fsatcl is not supported for this platform"
}
