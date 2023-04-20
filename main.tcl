package require starkit

if {[starkit::startup] ne "sourced"} {

encoding system utf-8
 
package require XOTcl
 
namespace import ::xotcl::*


lappend auto_path $::starkit::topdir
lappend auto_path [file join $::starkit::topdir lib xotcl1.5.2 lib]
lappend auto_path [file join $::starkit::topdir lib xotcl1.5.2 comm]
set progdir $::starkit::topdir

encoding system utf-8

Object IDE
package provide IDECore 1.0

package require EspBazaLingvo
package require EspSintaksaAnalizo

source [file join $progdir ideBgError.tcl]

EsperantoConf set programoDosierujo [file dirname $::starkit::topdir]
EsperantiloLancxilo lancxuEsperatnilo

} else {

encoding system utf-8

package require XOTcl
namespace import ::xotcl::*

Object IDE
Object IDE::System
IDE::System proc isTkNeverThan84 {} {
    global tk_version
    expr {$tk_version>=8.4}
}
Object IDEPreferences
IDEPreferences proc getParameter {name} {
    EsperantoConf getParameter $name
}
package provide IDECore 1.0
lappend auto_path $::starkit::topdir
set progdir $::starkit::topdir


}