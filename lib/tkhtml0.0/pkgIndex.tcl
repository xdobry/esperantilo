# Tcl package index file - handcrafted by kroc

global tcl_platform
switch -glob -- $tcl_platform(os) {
    "Win*"  { set libname tkhtml.windows }
    "Linux" { set libname tkhtml.linux }
    "SunOS" { set libname tkhtml.solaris }
}

if {[info exists libname]} {
	package ifneeded Tkhtml 0.0 [list load [file join $dir $libname]]
} else {
	puts stderr "\n\
		Sorry, I can't find Tkhtml library for your platform :\n\
		Linux, windows and Solaris only are provided in this starkit.\
		\n"
	exit
}
