# select directory based on platform were running on
# this is far from perfect, as Linux has various flavours of tcl_platform(machine) like i386,i486,i586,i686
#  
set __dir__ $dir
foreach index [concat \
                   [glob -nocomplain [file join $dir * pkgIndex.tcl]] \
                   [glob -nocomplain [file join $dir * * pkgIndex.tcl]]] {
  set dir [file dirname $index]
  source $index
}
set dir $__dir__
unset __dir__


global tcl_platform
if {$tcl_platform(os) eq "Linux"} {
    package ifneeded XOTcl 1.6.0 [list load [file join $dir libxotcl1.6.0.so]]
} 
if {$tcl_platform(platform) eq "windows"} {
    package ifneeded XOTcl 1.6.0 [list load [file join $dir libxotcl1.6.dll]]
}
