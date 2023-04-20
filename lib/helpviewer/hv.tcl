################################################################################
#
# This script originaly comes with TkHtml package : www.hwaci.com/sw/tkhtml
#
# and was written by Dr Richard Hipp <drh@acm.org>
#
# starkit support by :
#
# Jean-Claude Wippler <jcw@equi4.com> and David Zolli <kroc@kroc.tk>
#
################################################################################

package require msgcat

# Standalone use or not :
if {[catch "winfo exist ."]} {
    # standalone : we hide .
    package require Tk
    wm withdraw .
    set exit_cde "exit"
} elseif {![string length [winfo children .]]} {
    # special case for windows :
    wm withdraw .
    set exit_cde "exit"
} else {
    # Invoke from another Tk app :
    set exit_cde "wm withdraw .help"
}

package require Tkhtml
::msgcat::mcload $::starkit::topdir/lib/helpviewer
if {![winfo exist .help]} {
    toplevel .help
    wm title .help [::msgcat::mc "Help"]
    wm iconname .help [::msgcat::mc "Help"]
    set Dx [expr ([winfo screenwidth .]-640)/3]
    set Dy [expr ([winfo screenheight .]-480)/3]
    wm geometry .help 640x480+$Dx+$Dy
} else {
    wm deiconify .help
}

set HtmlTraceMask 0
set file {}

# These images are used in place of GIFs or of form elements
#
image create photo biggray -data {
    R0lGODdhPAA+APAAALi4uAAAACwAAAAAPAA+AAACQISPqcvtD6OctNqLs968+w+G4kiW5omm
    6sq27gvH8kzX9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNFgsAO///
}
image create photo smgray -data {
    R0lGODdhOAAYAPAAALi4uAAAACwAAAAAOAAYAAACI4SPqcvtD6OctNqLs968+w+G4kiW5omm
    6sq27gvH8kzX9m0VADv/
}
image create photo nogifbig -data {
    R0lGODdhJAAkAPEAAACQkADQ0PgAAAAAACwAAAAAJAAkAAACmISPqcsQD6OcdJqKM71PeK15
    AsSJH0iZY1CqqKSurfsGsex08XuTuU7L9HywHWZILAaVJssvgoREk5PolFo1XrHZ29IZ8oo0
    HKEYVDYbyc/jFhz2otvdcyZdF68qeKh2DZd3AtS0QWcDSDgWKJXY+MXS9qY4+JA2+Vho+YPp
    FzSjiTIEWslDQ1rDhPOY2sXVOgeb2kBbu1AAADv/
}
image create photo nogifsm -data {
    R0lGODdhEAAQAPEAAACQkADQ0PgAAAAAACwAAAAAEAAQAAACNISPacHtD4IQz80QJ60as25d
    3idKZdR0IIOm2ta0Lhw/Lz2S1JqvK8ozbTKlEIVYceWSjwIAO///
}

# Construct the main window
#
if {![winfo exist .help.mbar]} {    
    frame .help.mbar -bd 2 -relief raised
    pack .help.mbar -side top -fill x
    menubutton .help.mbar.file -text File -underline 0 -menu .mbar.file.m
    # pack .mbar.file -side left -padx 5
    set m [menu .help.mbar.file.m]
    $m add command -label Open -underline 0 -command Load
    $m add command -label Refresh -underline 0 -command Refresh
    $m add separator
    $m add command -label Exit -underline 1 -command $exit_cde
    menubutton .help.mbar.view -text View -underline 0 -menu .mbar.view.m
    # pack .mbar.view -side left -padx 5
    set m [menu .help.mbar.view.m]
    set underlineHyper 0
    $m add checkbutton -label {Underline Hyperlinks} -variable underlineHyper
    trace variable underlineHyper w ChangeUnderline
    proc ChangeUnderline args {
        global underlineHyper
        .help.h.h config -underlinehyperlinks $underlineHyper
    }
    set showTableStruct 0
    $m add checkbutton -label {Show Table Structure} -variable showTableStruct
    trace variable showTableStruct w ShowTableStruct
    proc ShowTableStruct args {
        global showTableStruct HtmlTraceMask
        if {$showTableStruct} {
            set HtmlTraceMask [expr {$HtmlTraceMask|0x8}]
            .help.h.h config -tablerelief flat
        } else {
            set HtmlTraceMask [expr {$HtmlTraceMask&~0x8}]
            .help.h.h config -tablerelief raised
        }
        Refresh
    }
    set showImages 1
    $m add checkbutton -label {Show Images} -variable showImages
    trace variable showImages w Refresh
    
    # Construct the main HTML viewer
    #
    frame .help.h
    pack .help.h -side top -fill both -expand 1
    #-xscrollcommand {.f2.hsb set}
    html .help.h.h \
            -yscrollcommand {.help.h.vsb set} \
            -padx 5 \
            -pady 9 \
            -formcommand FormCmd \
            -imagecommand ImageCmd \
            -scriptcommand ScriptCmd \
            -appletcommand AppletCmd \
            -underlinehyperlinks 0 \
            -unvisitedcolor red \
            -bg white -tablerelief raised
    
    # If the tracemask is not 0, then draw the outline of all
    # tables as a blank line, not a 3D relief.
    #
    if {$HtmlTraceMask} {
        .help.h.h config -tablerelief flat
    }
    
    # A font chooser routine.
    #
    # .help.h.h config -fontcommand pickFont
    proc pickFont {size attrs} {
        puts "FontCmd: $size $attrs"
        set a [expr {-1<[lsearch $attrs fixed]?{courier}:{charter}}]
        set b [expr {-1<[lsearch $attrs italic]?{italic}:{roman}}]
        set c [expr {-1<[lsearch $attrs bold]?{bold}:{normal}}]
        set d [expr {int(12*pow(1.2,$size-4))}]
        list $a $d $b $c
    }
    
    # This routine is called for each form element
    #
    proc FormCmd {n cmd args} {
        # puts "FormCmd: $n $cmd $args"
        switch $cmd {
            select -
            textarea -
            input {
                set w [lindex $args 0]
                label $w -image nogifsm
            }
        }
    }
    
    # This routine is called for every <IMG> markup
    #
    # proc ImageCmd {args} {
    # puts "image: $args"
    #   set fn [lindex $args 0]
    #   if {[catch {image create photo -file $fn} img]} {
    #     return nogifsm
    #   } else {
    #    global Images
    #    set Images($img) 1
    #    return $img
    #  }
    #}
    proc ImageCmd {args} {
        global OldImages Images showImages
        if {!$showImages} {
            return smgray
        }
        set fn [lindex $args 0]
        if {[info exists OldImages($fn)]} {
            set Images($fn) $OldImages($fn)
            unset OldImages($fn)
            return $Images($fn)
        }
        if {[catch {image create photo -file $fn} img]} {
            return smgray
        }
        if {[image width $img]*[image height $img]>20000} {
            global BigImages
            set b [image create photo -width [image width $img] \
                    -height [image height $img]]
            set BigImages($b) $img
            set img $b
            after idle "MoveBigImage $b"
        }
        set Images($fn) $img
        return $img
    }
    proc MoveBigImage b {
        global BigImages
        if {![info exists BigImages($b)]} return
        $b copy $BigImages($b)
        image delete $BigImages($b)
        unset BigImages($b)
        update
    }
    
    
    # This routine is called for every <SCRIPT> markup
    #
    proc ScriptCmd {args} {
        # puts "ScriptCmd: $args"
    }
    
    # This routine is called for every <APPLET> markup
    #
    proc AppletCmd {w arglist} {
        # puts "AppletCmd: w=$w arglist=$arglist"
        label $w -text "The Applet $w" -bd 2 -relief raised
    }
    
    # This procedure is called when the user clicks on a hyperlink.
    # See the "bind .help.h.h.x" below for the binding that invokes this
    # procedure
    #
    proc HrefBinding {x y} {
        set new [.help.h.h href $x $y]
        # puts "link to [list $new]"; return
        if {$new!=""} {
            set pattern $::LastFile#
            set len [string length $pattern]
            incr len -1
            if {[string range $new 0 $len]==$pattern} {
                incr len
                .help.h.h yview [string range $new $len end]
            } else {
                LoadFile $new
            }
        }
    }
    bind .help.h.h.x <1> {HrefBinding %x %y}
    
    # Pack the HTML widget into the main screen.
    #
    pack .help.h.h -side left -fill both -expand 1
    scrollbar .help.h.vsb -orient vertical -command {.help.h.h yview}
    pack .help.h.vsb -side left -fill y
    focus .help.h.vsb
    
    #frame .help.f2
    #pack .help.f2 -side top -fill x
    #frame .help.f2.sp -width [winfo reqwidth .help.h.vsb] -bd 2 -relief raised
    #pack .help.f2.sp -side right -fill y
    #scrollbar .help.f2.hsb -orient horizontal -command {.help.h.h xview}
    #pack .help.f2.hsb -side top -fill x
    
    # This procedure is called when the user selects the File/Open
    # menu option.
    #
    set lastDir [pwd]
    proc Load {} {
        set filetypes {
            {{Html Files} {.html .htm}}
            {{All Files} *}
        }
        global lastDir htmltext
        set f [tk_getOpenFile -initialdir $lastDir -filetypes $filetypes]
        if {$f!=""} {
            LoadFile $f
            set lastDir [file dirname $f]
        }
    }
    
    # Clear the screen.
    #
    # Clear the screen.
    #
    proc Clear {} {
        global Images OldImages hotkey
        if {[winfo exists .help.fs.h]} {set w .help.fs.h} {set w .help.h.h}
        $w clear
        catch {unset hotkey}
        ClearBigImages
        ClearOldImages
        foreach fn [array names Images] {
            set OldImages($fn) $Images($fn)
        }
        catch {unset Images}
    }
    proc ClearOldImages {} {
        global OldImages
        foreach fn [array names OldImages] {
            image delete $OldImages($fn)
        }
        catch {unset OldImages}
    }
    proc ClearBigImages {} {
        global BigImages
        foreach b [array names BigImages] {
            image delete $BigImages($b)
        }
        catch {unset BigImages}
    }
    
    # Read a file
    #
    proc ReadFile {name} {
        if {[catch {open $name r} fp]} {
            tk_messageBox -icon error -message $fp -type ok
            return {}
        } else {
            fconfigure $fp -translation binary
            set r [read $fp [file size $name]]
            close $fp
            return $r
        }
    }
    
    # Load a file into the HTML widget
    #
    proc LoadFile {name} {
        # jcw 06/10/2000 - drop "#tag", if present
        set basename [lindex [split $name #] 0]
        set html [ReadFile $basename]
        if {$html==""} return
        Clear
        # jcw: new code for back/forward history
        #   PrevFiles are previous pages, last seen is at end
        #   NextFiles are next pages, pushed back while retreating
        #puts "$name: $PrevFiles << $LastFile >> $NextFiles"
        if {$name != $::LastFile && $::LastFile != ""} {
            if {$name == [lindex $::PrevFiles end]} {
                set ::NextFiles [linsert $::NextFiles 0 $::LastFile]
                set ::PrevFiles [lreplace $::PrevFiles end end]
            } else {
                lappend ::PrevFiles $::LastFile
                if {$name == [lindex $::NextFiles 0]} {
                    set ::NextFiles [lrange $::NextFiles 1 end]
                } else {
                    set ::NextFiles {}
                }
            }
        }
        # kroc : display title if available :
        if {[string first <title> [string tolower $html]] != -1 && \
                    [string first </title> [string tolower $html]]} {
            set l1 [expr [string first <title> [string tolower $html]]+7]
            set l2 [expr [string first </title> [string tolower $html]]-1]
            wm title .help [string range $html $l1 $l2]
        } else {
            wm title .help $name
        }
        # jcw: end of new code
        set ::LastFile $name
        .help.h.h config -base $name
        # jcw 06/10/2000 - deal with text files (as suggested by Uwe Koloska)
        if {![regexp -nocase {<html>|<!doctype|<body} [string range $html 0 200]]} {
            set html "<pre>$html</pre>\n"
        }
        # jcw: end of changed code
        .help.h.h parse $html
        ClearOldImages
    }
    
    # Refresh the current file.
    #
    proc Refresh {args} {
        if {![info exists ::LastFile]} return
        LoadFile $::LastFile
    }
    
    # jcw: init
    set ::LastFile {}
    set ::PrevFiles {}
    set ::NextFiles {}
    
    # kroc : basic browse buttons :
    
    set m .help.mbar.view.m
    button .help.mbar.i -text [::msgcat::mc "Table of content"] -command {
        set FileTest [lindex $::PrevFiles 0]
        if {$FileTest != ""} {
            LoadFile $FileTest
        } else {
            LoadFile index.html
        }
    }
    pack .help.mbar.i -side left -padx 5
    button .help.mbar.b -text [::msgcat::mc "Previous"] -command {
        set FileTest [lindex $::PrevFiles end]
        if {$FileTest != ""} {
            LoadFile $FileTest
        }
    }
    pack .help.mbar.b -side left -padx 5
    button .help.mbar.f -text [::msgcat::mc "Next"] -command {
        set FileTest [lindex $::NextFiles end]
        if {$FileTest != ""} {
            LoadFile $FileTest
        }
    }
    pack .help.mbar.f -side left -padx 15
    button .help.mbar.q -text [::msgcat::mc "Exit"] -command "$exit_cde"
    pack .help.mbar.q -side left -padx 15
    
    # jcw: menu bindings (disabled)
    # $m add separator
    # $m add command -label Home -underline 1 -command {LoadFile [lindex $PrevFiles 0]}
    # $m add command -label Back -underline 1 -command {LoadFile [lindex $PrevFiles end]}
    # $m add command -label Forward -underline 1 -command {LoadFile [lindex $NextFiles 0]}
    
    # end of kroc changes
    
    
    # This binding changes the cursor when the mouse move over
    # top of a hyperlink.
    #
    
    bind HtmlClip <Motion> {
        set parent [winfo parent %W]
        set url [$parent href %x %y]
        if {[string length $url] > 0} {
            $parent configure -cursor hand2
        } else {
            $parent configure -cursor {}
        }
    }
    
    # kroc: Wheelmouse support :
    set ::bindtgt .help.h.h.x
    bind $::bindtgt <4> { $::bindtgt yview scroll -3 units }
    bind $::bindtgt <5> { $::bindtgt yview scroll 3 units }
    bind .help <MouseWheel> { $::bindtgt yview scroll [expr {-%D/60}] units }
    
    # kroc: close app correctly
    bind .help <Destroy> "$exit_cde"
    
    # kroc: underline links :
    .help.h.h config -underlinehyperlinks 1
    update
    
    # kroc: we define i18n and common index file names list
    # first inside starkit then outside :
    set i18n_i [string range [::msgcat::mclocale] 0 1]
    set index_files {}
    set index_found 0
    lappend index_files [file join $::starkit::topdir html ${i18n_i}.htm]
    lappend index_files [file join $::starkit::topdir html ${i18n_i}.html]
    lappend index_files [file join $::starkit::topdir html index.htm]
    lappend index_files [file join $::starkit::topdir html index.html]
    lappend index_files ${i18n_i}.htm
    lappend index_files ${i18n_i}.html
    lappend index_files index.htm
    lappend index_files index.html
    
    # And we try to load locale before index.htm*
    foreach index_file $index_files {
        puts "search $index_file"
        if {[file exist $index_file]} {
            puts "fond $index_file"
            set ::LastFile [file tail $index_file]
            cd [file dirname $index_file]
            LoadFile $::LastFile
            .help.mbar.i configure -command [list LoadFile $::LastFile]
            set index_found 1
            break
        }
    }
    
    # Exit if none found :
    if !$index_found {
        tk_messageBox -icon error -type ok \
                -message [::msgcat::mc "No index found!"]
        exit
    } elseif {[info exist help_called]} {
        lappend ::PrevFiles $::LastFile
        set ::NextFiles ""
        set ::LastFile $help_called
        Refresh
    }
    
} else {
    # Try to display page provided by caller if it exists :
    # lappend ::PrevFiles $::LastFile
    # set ::NextFiles ""
    # set ::LastFile $help_called
    Refresh
    raise .help
}