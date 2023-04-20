#! /usr/bin/wish -f

# Synopsis:
# tclmacq [options]
#
# Options are:
#
# -l language	- set language of the interface (must be present in the
#		  language file)
# -c file	- configuration file name with language settings
# -G file	- guesses file name
# -m file	- mmorph file name (not used yet)
# -f font	- font specification for displaying guesses
# -e encoding	- encoding name for guesses (e.g. iso8859-2)


# some variables you may want to change
# name of the directory where supporting files (named below) reside
set tclmacqdir "/usr/local/lib"
# name of the file where tcl scripts reside
set tclmacqbindir "/usr/local/bin"
# name of file with language related information
set languagefile "$tclmacqdir/tclmacq-lang.txt"
# file with documentation
set helpFile "$tclmacqdir/tclmacq-help.txt"
# script sorting the attributes
set sortatt "$tclmacqbindir/sortatt.pl"
# script creating separate entries for each alternative in mmorph output
set simplify "$tclmacqbindir/simplify.pl"
# how mmorph should be invoked
set mmorph "mmorph"
# name of the file that is input for mmorph (preamble + our definitions)
set morphdesc "morphdesc"
# the input file for mmorph without the lexicon
set preamble "preamble"
# File that specifies which features to change to get required results
# from mmorph
set paradigmFile "paradigm"
# initial font for text fields
set textFont "-*-helvetica-*-r-*-*-12-*-*-*-*-*-iso8859-1"
# file to which remaining (unsolved) guesses are saved
set guessSave "rem_guess"
# file with guesses
set readFile ""
# results file
set resultsFile "results"
# initial font for menus
set fontName $textFont
# Whether saving a description removes the word form.
# 0 - not at all
# 1 - only current
# 2 - all word forms that have that description
set saver 2
# Whether alternatives in mmorph output should be resolved
# 0 - no
# 1 - yes
set alternatives 0
# encoding for guesses
set encoding "iso8859-1"
# marks encoding in help and language files
set encChar "%"

# selected descriptions
set results ""
# indicates whether the descriptions where saved
set descSaved 1
# undo list
set undoList {}
# Statistics
set deleted 0
set firstCorrect 0
set anyCorrect 0
set precision 0
set currentUntouched 1
set totalEntries 0
set noSaved 0

set parLabels ""
# first see what the parameters are
# guess file must have capital G due to tcl/tk stupid restrictions
for {set i 0} {$i < $argc} {incr i 1} {
    if {[string range [lindex $argv $i] 0 0] == "-"} {
	switch [string range [lindex $argv $i] 1 end] {
	    "l" {
		if {[expr $i + 1] < $argc} {
		    set parLabels [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing language name"
		}
	    }
	    "c" {
		if {[expr $i + 1] < $argc} {
		    set languagefile [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing language information file name"
		}
	    }
	    "G" {
		if {[expr $i + 1] < $argc} {
		    set readFile [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing predictions file name"
		}
	    }
	    "m" {
		if {[expr $i + 1] < $argc} {
		    set mmorphFile [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing mmorph file name"
		}
	    }
	    "f" {
		if {[expr $i + 1] < $argc} {
		    set textFont [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing text font name"
		}
	    }
	    "e" {
		if {[expr $i + 1] < $argc} {
		    set encoding [lindex $argv [expr $i + 1]]
		} else {
		    puts stderr "Missing encoding name"
		}
	    }
	}
    }
}


proc setDefaultNames {} {
    global toolName fileName fileU cust custU help helpU openGu openGuU
    global saveDesc saveDescU tExit tExitU lang langU font fontU word
    global mmorphOut descr saveButt saveButtU exitButt exitButtU
    global exitShort saveShort mmorphShort fileShort custShort helpShort
    global mmorphButt mmorphButtU fontName globalLanguage dnst dns
    global saveButtMsg dontSaveButtMsg wordRemove wordRemoveU 
    global wordOpen wordOpenU editButt editButtU saveRemoves
    global saveRAll cancel sortattLab mmorphLab morphdescLab 
    global guessSaveLab undoButt undoButtU simp no yes removeShort matchButt
    global matchButtU matchShort loadShort undoShort editShort paraLab
    global replaceButt replaceButtU replShort replLab1 replLab2 add delete
    global set changePOS printStats printStatsU

    set globalLanguage English
    set toolName  "Morphological dictionary acquisition tool"
    set fileName  File
    set fileU 0
    set cust cusTomize
    set custU 3
    set help Help
    set helpU 0
    set openGu "Open guesses"
    set openGuU 0
    set saveDesc "Save descriptions"
    set saveDescU 0
    set tExit Exit
    set tExitU 0
    set lang Language
    set langU 0
    set font Font
    set fontU 0
    set word "Word form:"
    set mmorphOut "Mmorph output:"
    set descr "Descriptions:"
    set exitButt Exit
    set exitButtU 0
    set saveButt Save
    set saveButtU 0
    set mmorphButt Mmorph
    set mmorphButtU 0
    set exitShort "<M-KeyPress-e>"
    set saveShort "<M-KeyPress-s>"
    set mmorphShort "<M-KeyPress-m>"
    set fileShort "<M-KeyPress-f>"
    set custShort "<M-KeyPress-t>"
    set helpShort "<M-KeyPress-h>"
    set removeShort "<M-KeyPress-d>"
    set matchShort "<M-KeyPress-a>"
    set loadShort "<M-KeyPress-l>"
    set undoShort "<M-KeyPress-u>"
    set editShort "<M-KeyPress-c>"
    set replShort "<M-KeyPress-r>"
    set dnst "Descriptions not saved"
    set dns "Descriptions have not been saved."
    set saveButtMsg Save
    set dontSaveButtMsg "Don't save"
    set wordRemove "Delete"
    set wordRemoveU 0
    set wordOpen "Load new"
    set wordOpenU 0
    set editButt Correct
    set editButtU 0
    set saveRemoves "   Save removes:"
    set saveRAll "all"
    set cancel "cancel"
    set sortattLab "sorting script"
    set mmorphLab "mmorph invocation"
    set morphdescLab "mmorph input file"
    set guessSave "rem_guess"
    set guessSaveLab "remaining guesses file name"
    set undoButt "Undo"
    set undoButtU 0
    set simp "  Resolve alternatives:"
    set no "no"
    set yes "yes"
    set matchButt "mAtch mmorph"
    set matchButtU 1
    set paraLab "paradigm file"
    set replaceButt "Replace"
    set replaceButtU 0
    set replLab1 "Replace:"
    set replLab2 "with:"
    set add "Add"
    set delete "Delete"
    set set "Set"
    set changePOS "Change POS"
    set printStats "Print statistics"
    set printStatsU 0
}

setDefaultNames

# create window

frame .fr -width 25c -height 50c
pack .fr -expand 1 -fill both


# add menus
frame .menubar -relief raised -bd 2 -height 1c
pack .menubar -in .fr -fill x -anchor n -side top
menubutton .menubar.file -text $fileName -underline $fileU -menu .menubar.file.menu
menubutton .menubar.customize -text $cust -underline $custU -menu .menubar.customize.menu
menubutton .menubar.help -text $help -underline $helpU -menu .menubar.help.menu
pack .menubar.file .menubar.customize -side left
pack .menubar.help -side right

# add pulldown menus
menu .menubar.file.menu
.menubar.file.menu add command -label $openGu -underline $openGuU \
	-command OpenFile
.menubar.file.menu add command -label $saveDesc -underline $saveDescU \
	-command {saveDesc}
.menubar.file.menu add command -label $printStats -underline $printStatsU \
	-command {printStatistics}
.menubar.file.menu add command -label $tExit -underline $tExitU \
	-command {exitProg}

menu .menubar.customize.menu
.menubar.customize.menu add cascade -label $lang -underline $langU -menu .menubar.customize.menu.lang
.menubar.customize.menu add command -label $font -underline $fontU -command FontPopup
.menubar.customize.menu add command -label $sortattLab -command {editStr $sortattLab sortatt}
.menubar.customize.menu add command -label $mmorphLab -command {editStr $mmorphLab mmorph}
.menubar.customize.menu add command -label $morphdescLab -command {editStr $morphdescLab morphdesc}
.menubar.customize.menu add command -label $guessSaveLab -command {editStr $guessSaveLab guessSave}
.menubar.customize.menu add command -label $paraLab \
	-command {editStr $paradigmFile}

menu .menubar.customize.menu.lang
.menubar.customize.menu.lang add command -label English -command {setLabels English}

menu .menubar.help.menu
.menubar.help.menu add command -label $help -underline $helpU -command {DispHelp}

tk_menuBar .menubar .menubar.file .menubar.customize


proc setNames {language} {
    global languagefile toolName fileName fileU cust custU help helpU openGu
    global openGuU saveDesc saveDescU tExit tExitU lang langU font fontU
    global word mmorphOut descr saveButtU saveButt  exitButt exitbuttU
    global exitShort saveShort mmorphShort fileShort custShort helpShort
    global fontName globalLanguage wordRemove wordRemoveU 
    global wordOpen wordOpenU editButt editButtU saveRemoves saveRAll cancel
    global sortattLab mmorphLab morphdescLab guessSaveLab undoButt undoButtU
    global simp yes no matchButt matchButtU matchShort replaceButt replaceButtU
    global replShort add delete set changePOS printStats printStatsU encChar

    set globalLanguage $language
    .menubar.customize.menu.lang delete 0 end
    .menubar.customize.menu.lang add command -label English -command {setLabels English}
    set insection 0
    set f1 [open $languagefile r]
    if {![eof $f1]} {
	set langline [gets $f1]
	set commentchar [string range $langline 0 0]
    }
    while {![eof $f1]} {
	set langline [gets $f1]
	if {[string range $langline 0 0] != $commentchar} {
	    if {[string range $langline 0 0] == " "} {
		if {$insection == 1} {
		    set langline [string trim $langline " \t"]
		    set si [string first " " $langline]
		    if {$si == -1} {
			set si [string first "\t" $langline]
		    }
		    if {$si > [string first "\t" $langline]} {
			set si [string first "\t" $langline]
		    }
		    set var [string range $langline 0 [expr $si - 1]]
		    set val [string trim [string range $langline \
			    [expr $si + 1] 10000] " \t\""]
		    set $var $val
		}
	    } else {
		set langline [string trim $langline " \t"]
		if {$langline != ""} {
		    if {[string range $langline 0 0] != $encChar} {
			.menubar.customize.menu.lang add command -label $langline -command [list setLabels $langline]
		    }
		}
		if {[string range $langline 0 0] == $encChar} {
		    #fconfigure $f1 -encoding [string range $langline 1 end]
		} elseif {$langline == $language} {
		    set insection 1
		} else {
		    set insection 0
		}
	    }
	}
    }
    close $f1
}

setNames English

wm title . $toolName
wm minsize . 1 1


# add worform
frame .fr.wordform
pack .fr.wordform -fill both -expand 1
label .fr.wordform.lab -text $word
listbox .fr.wordform.text -font $textFont -width 120 -height 6 -bg grey -yscrollcommand ".fr.wordform.ys set"
.fr.wordform.text configure -selectmode single
scrollbar .fr.wordform.ys -command ".fr.wordform.text yview"
pack .fr.wordform.lab -in .fr.wordform -side top -anchor w
pack .fr.wordform.ys -in .fr.wordform -side right -fill y
pack .fr.wordform.text -in .fr.wordform -side bottom -expand 1 -fill both

# add wordform buttons
frame .fr.wordbutt
pack .fr.wordbutt -fill x
button .fr.wordbutt.remove -text $wordRemove -underline $wordRemoveU -command removeWord
#button .fr.wordbutt.desc -text $wordDesc -underline $wordDescU -command ShowDesc
button .fr.wordbutt.open -text $wordOpen -underline $wordOpenU -command OpenFile
pack .fr.wordbutt.remove -side left -anchor w
#pack .fr.wordbutt.desc -side left -anchor w
pack .fr.wordbutt.open -side left -anchor w

# add descriptions
frame .fr.desc
pack .fr.desc -fill both -expand 1
label .fr.desc.lab -text $descr
listbox .fr.desc.text -font $textFont -width 120 -height 10 -bg grey -yscrollcommand ".fr.desc.ys set"
.fr.desc.text configure -selectmode extended
scrollbar .fr.desc.ys -command ".fr.desc.text yview"
pack .fr.desc.lab -in .fr.desc -side top -anchor w
pack .fr.desc.ys -in .fr.desc -side right -fill y
pack .fr.desc.text -in .fr.desc -side top -fill both -expand 1

# add description buttons
frame .fr.descbutt
pack .fr.descbutt -fill x
button .fr.descbutt.mmorph -text "Mmorph" -underline 0
button .fr.descbutt.save -text $saveButt -underline 0 -command {saveOneDesc}
button .fr.descbutt.edit -text $editButt -underline $editButtU -command EditPopup
button .fr.descbutt.undo -text $undoButt -underline $undoButtU -command undoOp
label .fr.descbutt.srlab -text $saveRemoves
radiobutton .fr.descbutt.rb0 -text "0" -variable saver -value 0 -anchor w
radiobutton .fr.descbutt.rb1 -text "1" -variable saver -value 1 -anchor w
radiobutton .fr.descbutt.rba -text $saveRAll -variable saver -value 2 -anchor w
pack .fr.descbutt.mmorph -side left -anchor w
pack .fr.descbutt.save -side left -anchor w
pack .fr.descbutt.edit -side left -anchor w
pack .fr.descbutt.undo -side left -anchor w
pack .fr.descbutt.srlab -side left -anchor w
pack .fr.descbutt.rb0 -side left
pack .fr.descbutt.rb1 -side left
pack .fr.descbutt.rba -side left

# add mmorph output
frame .fr.mmorph
pack .fr.mmorph -fill both -expand 1
label .fr.mmorph.lab -text $mmorphOut
#!listbox .fr.mmorph.text -font $textFont -width 120 -height 20 -bg grey -yscrollcommand ".fr.mmorph.ys set"
text .fr.mmorph.text -font $textFont -width 120 -height 20 -bg grey -yscrollcommand ".fr.mmorph.ys set"
scrollbar .fr.mmorph.ys -command ".fr.mmorph.text yview"
pack .fr.mmorph.lab -in .fr.mmorph -side top -anchor w
pack .fr.mmorph.ys -in .fr.mmorph -side right -fill y
pack .fr.mmorph.text -in .fr.mmorph -side bottom -fill both -expand 1

# add final buttons
frame .fr.butt
pack .fr.butt -fill x
button .fr.butt.match -text $matchButt -underline $matchButtU -command {matchMmorph}
pack .fr.butt.match -side left
button .fr.butt.repl -text $replaceButt -underline $replaceButtU -command {replaceMmorph}
pack .fr.butt.repl -side left
label .fr.butt.slab -text $simp
pack .fr.butt.slab -side left
radiobutton .fr.butt.s0 -text $no -variable alternatives -value 0 -anchor w
pack .fr.butt.s0 -side left
radiobutton .fr.butt.s1 -text $yes -variable alternatives -value 1 -anchor w
pack .fr.butt.s1 -side left
button .fr.butt.exit -text $exitButt -underline $exitButtU -command {exitProg}
pack .fr.butt.exit -side right


# we need this for file selection
source $tclmacqbindir/filesel.tcl


proc mySplit {str delim} {

#    puts stderr "mySplit($str, $delim)"
    set a {}
    set l [string length $delim]
    set i [string first $delim $str]
    while {$i >= 0} {
	lappend a [string range $str 0 [expr $i - 1]]
	set str [string range $str [expr $i + $l] [string length $str]]
	set i [string first $delim $str]
    }
    lappend a $str
#    puts stderr "The array is $a"
    return $a
}

# read fsa_guess output
proc OpenFile {} {
    global fileselect oldname

    fileselect
    tkwait window .fileSelectWindow
    set kupa [array get fileselect selectedfile]
    if {$kupa != ""} {
	set oldname $fileselect(selectedfile)
	ReadFile $fileselect(selectedfile)
    }
}

proc ReadFile {opFileName} {
    global predictions textFont totalEntries perEntry encoding

    set openf $opFileName
    .fr.wordform.text delete 0 end
    set fid [open $openf r]
    #fconfigure $fid -encoding $encoding

    set totalEntries 0
    set perEntry 0
    while {![eof $fid]} {
	set fl [gets $fid]
	set i [string first ": " $fl]
	set word [string range $fl 0 [expr $i - 1] ]
	set predictions($word) [string range $fl [expr $i + 2] end]
	.fr.wordform.text insert end $word
	incr totalEntries
	incr perEntry [llength [mySplit $predictions($word) ", "]]
    }
    close $fid
    set perEntry [expr "$perEntry.0" / $totalEntries]
    .fr.wordform.text activate 0
    .fr.wordform.text selection set 0
    ShowDesc
    .fr.wordform.text activate 0
    .fr.wordform.text selection set 0
}

proc ShowDesc {} {
    global predictions

    .fr.desc.text delete 0 end
    if { [.fr.wordform.text curselection] != "" } {
	set cs [.fr.wordform.text get [.fr.wordform.text curselection]]
    } else {
	set cs [.fr.wordform.text get active]
    }
    set ds $predictions($cs)
    for {set it [string first ", " $ds]} {$it != -1}\
	    {set it [string first ", " $ds]} {
	set w [string range $ds 0 [expr $it - 1] ]
	.fr.desc.text insert end $w
	set ds [string range $ds [expr $it + 2] end]
    }
    .fr.desc.text insert end $ds
}


proc GenMmorph {} {
    global morphdesc mmorph preamble sortatt alternatives simplify encoding

    .fr.mmorph.text delete 0.0 end
    set cs [.fr.desc.text curselection]
    set lastactive [.fr.desc.text index active]
    encoding system $encoding
    if {[llength $cs] == 1 || [llength  $cs] == 2} {

	# generate all forms from mmorph description
	exec cp $preamble $morphdesc
	set f1 [open $morphdesc a]
	#fconfigure $f1 -encoding $encoding
	if {[llength $cs] == 1} {
	    puts $f1 [.fr.desc.text get $cs]
	    set mm  "mm"
	} else {
	    puts $f1 [.fr.desc.text get [lindex $cs 0]]
	    set mm  "tmp1"
	}
	close $f1
	exec cat /dev/null | $mmorph -c -m $morphdesc > /dev/null
	if {$alternatives == 0} {
	    exec $mmorph -q -m $morphdesc | $sortatt > $mm
	} else {
	    exec $mmorph -q -m $morphdesc | $simplify | $sortatt > $mm
	}
	set mm "mm"

	if {[llength $cs] == 2} {
	    exec cp $preamble $morphdesc
	    set f2 [open $morphdesc a]
	    #fconfigure $f2 -encoding $encoding
	    puts $f2 [.fr.desc.text get [lindex $cs 1]]
	    close $f2
	    exec cat /dev/null | $mmorph -c -m $morphdesc > /dev/null
	    if {$alternatives == 0} {
		exec $mmorph -q -m $morphdesc | $sortatt > tmp2
	    } else {
		exec $mmorph -q -m $morphdesc | $sortatt | $simplify > tmp2
	    }
	    catch {exec diff tmp1 tmp2 | grep "^\[><\]" | $sortatt > $mm}
	}
	set f4 [open $mm r]
	#fconfigure $f4 -encoding $encoding
	while {![eof $f4]} {
	    set mexp [gets $f4]
	    #!.fr.mmorph.text insert end $mexp
	    .fr.mmorph.text insert end [format "%s%c" $mexp 10]
	}
	close $f4
    }
    .fr.desc.text activate $lastactive
}

bind .fr.descbutt.mmorph <Button> {GenMmorph}

bind . $exitShort {exitProg}
# That crap tcl/tk doesn't provide any method to normally invoke the menu
# Use F10, then cursor keys or keys without modifiers
bind . $fileShort {.menubar.file.menu post %x %y}
bind . $custShort {.menubar.customize.menu post %x %y}
bind . $mmorphShort {GenMmorph}
bind . $removeShort {removeWord}
bind . $matchShort {matchMmorph}
bind . $saveShort {saveOneDesc}
bind . $helpShort {DispHelp}
bind . $loadShort {OpenFile}
bind . $undoShort {undoOp}
bind . $editShort {EditPopup}
bind . $replShort {replaceMmorph}
bind .fr.wordform.text $fileShort {.menubar.file.menu post %x %y}
bind .fr.wordform.text $custShort {.menubar.customize.menu post %x %y}
bind .fr.wordform.text $mmorphShort {GenMmorph}
bind .fr.wordform.text $removeShort {removeWord}
bind .fr.wordform.text $matchShort {matchMmorph}
bind .fr.wordform.text $saveShort {saveOneDesc}
bind .fr.wordform.text $helpShort {DispHelp}
bind .fr.wordform.text $loadShort {OpenFile}
bind .fr.wordform.text $undoShort {undoOp}
bind .fr.wordform.text $editShort {EditPopup}
bind .fr.wordform.text $replShort {replaceMmorph}
bind .fr.desc.text $fileShort {.menubar.file.menu post %x %y}
bind .fr.desc.text $custShort {.menubar.customize.menu post %x %y}
bind .fr.desc.text $mmorphShort {GenMmorph}
bind .fr.desc.text $removeShort {removeWord}
bind .fr.desc.text $matchShort {matchMmorph}
bind .fr.desc.text $saveShort {saveOneDesc}
bind .fr.desc.text $helpShort {DispHelp}
bind .fr.desc.text $loadShort {OpenFile}
bind .fr.desc.text $undoShort {undoOp}
bind .fr.desc.text $editShort {EditPopup}
bind .fr.desc.text $replShort {replaceMmorph}
bind .fr.wordform.text <Down> {
    global currentUntouched

    .fr.wordform.text selection clear 0 end
    .fr.wordform.text selection set [expr [.fr.wordform.text index active] + 1]
    .fr.desc.text configure -selectbackground gray
    ShowDesc
    set currentUntouched 1
}
bind .fr.wordform.text <Up> {
    global currentUntouched

    .fr.wordform.text selection clear 0 end
    .fr.wordform.text selection set [expr [.fr.wordform.text index active] - 1]
    .fr.desc.text configure -selectbackground gray
    ShowDesc
    set currentUntouched 1
}
bind .fr.wordform.text <Prior> {
    global currentUntouched

    .fr.wordform.text selection clear 0 end
    if {[expr [.fr.wordform.text index active]\
	    - [.fr.wordform.text cget -height] + 2] > 0} {
	.fr.wordform.text selection set \
		[expr [.fr.wordform.text index active]\
		- [.fr.wordform.text cget -height] + 2]
    } else {
	.fr.wordform.text selection set 0
    }
    ShowDesc
    set currentUntouched 1
}
bind .fr.wordform.text <Next> {
    global currentUntouched

    .fr.wordform.text selection clear 0 end
    if {[expr [.fr.wordform.text index active]\
	    + [.fr.wordform.text cget -height] - 2] \
	    < [.fr.wordform.text index end]} {
	.fr.wordform.text selection set \
		[expr [.fr.wordform.text index active] + \
		[.fr.wordform.text cget -height] - 2]
    } else {
	.fr.wordform.text selection set end
    }
    ShowDesc
    set currentUntouched 1
}
bind .fr.wordform.text <Button-1> {
    global currentUntouched

    .fr.wordform.text activate [.fr.wordform.text nearest %y]
    .fr.wordform.text selection clear 0 end
    .fr.wordform.text selection set [.fr.wordform.text nearest %y]
    focus .fr.wordform.text
    .fr.desc.text configure -selectbackground gray
    ShowDesc
    set currentUntouched 1
}
bind .fr.desc.text <Button-1> {
    .fr.desc.text activate [.fr.wordform.text nearest %y]
    .fr.desc.text selection clear 0 end
    .fr.desc.text selection set [.fr.wordform.text nearest %y]
    focus .fr.desc.text
    .fr.desc.text configure -selectbackground gray
}
bind .fr.desc.text <Shift-Button-1> {
}
bind .fr.desc.text <Control-Button-1> {
}
bind .fr.desc.text <Down> {
    .fr.desc.text selection clear 0 end
    .fr.desc.text selection set [expr [.fr.desc.text index active] + 1]
    .fr.desc.text configure -selectbackground gray
}
bind .fr.desc.text <Up> {
    .fr.desc.text selection clear 0 end
    .fr.desc.text selection set [expr [.fr.desc.text index active] - 1]
    .fr.desc.text configure -selectbackground gray
}
bind .fr.desc.text <Prior> {
    .fr.desc.text selection clear 0 end
    if {[expr [.fr.desc.text index active]\
	    - [.fr.desc.text cget -height] + 2] > 0} {
	.fr.desc.text selection set \
		[expr [.fr.desc.text index active]\
		- [.fr.desc.text cget -height] + 2]
    } else {
	.fr.desc.text selection set 0
    }
    .fr.desc.text configure -selectbackground gray
}
bind .fr.desc.text <Next> {
    .fr.desc.text selection clear 0 end
    if {[expr [.fr.desc.text index active]\
	    + [.fr.desc.text cget -height] - 2] \
	    < [.fr.desc.text index end]} {
	.fr.desc.text selection set \
		[expr [.fr.desc.text index active] + \
		[.fr.desc.text cget -height] - 2]
    } else {
	.fr.desc.text selection set end
    }
    .fr.desc.text configure -selectbackground gray
}
bind .fr.desc.text <Button-3> {
    global attrTable add delete set changePOS fontName

    catch {destroy .pm}
    set i [.fr.desc.text nearest %y]
    set t [.fr.desc.text get $i]
    # extract POS and features from the description
    #extract POS
    set posi [string first "\[" $t]
    set pos [string range $t 0 [expr $posi - 1]]
    incr posi
    set tt [string range $t $posi [string length $t]]
    #extract features
    set fu {}
    while {[regexp -indices {[A-Za-z0-9_]+=[A-Za-z0-9_\|]+} $tt mv]} {
	# mv holds indices of a feature description
	set fd [string range $tt [lindex $mv 0] [lindex $mv 1]]
	set fi [string first "=" $fd]
	# feature name
	set fn [string range $fd 0 [expr $fi - 1]]
	# feature value
	set fv [split [string range $fd [expr $fi + 1] \
		[string length $fd]] "|"]
	lappend fu [list $fn $fv]
	set tt [string range $tt [lindex $mv 1] [string length $tt]]
    }
    set m [menu .pm]
    # create add menu
    set pma [menu .pm.add]
    set menuList [list .pm.add]
    $m add cascade -label $add -font $fontName -menu $pma
    foreach pp $typeTable {
	if {[lindex $pp 0] == $pos} {
	    # Now [lindex pp 1] has a list of all features of POS
	    foreach pa [lindex $pp 1] {
		set mi [menu .pm.add.$pa]
		lappend menuList .pm.add.$pa
		foreach ff $attrTable {
		    if {[lindex $ff 0] == $pa} {
			# Now [lindex $ff 1] has a list of values of feature
			foreach ff1 [lindex $ff 1] {
			    # filter out values already in the description
			    set found 0
			    foreach q1 $fu {
				if {[lindex $q1 0] == $pa} {
				    foreach q2 [lindex $q1 1] {
					if {$q2 == $ff1} {
					    set found 1
					}
				    }
				}
			    }
			    if {$found == 0} {
				$mi add command -label $ff1 -command \
					[list addRvalue $i $t $pa $ff1]
			    }
			}
		    }
		}
		$pma add cascade -label $pa -menu $mi
	    }
	}
    }
    # create delete menu
    set pmd [menu .pm.delete]
    lappend menuList .pm.delete
    $m add cascade -label $delete -font $fontName -menu $pmd
    foreach pp $fu {
	set pa [lindex $pp 0]
	set mi [menu .pm.delete.$pa]
	lappend menuList $mi
	foreach ff1 [lindex $pp 1] {
	    $mi add command -label $ff1 -command \
		    [list deleteRvalue $i $t $pa $ff1]
	}
	$pmd add cascade -label $pa -menu $mi
    }
    # create set menu
    set pms [menu .pm.set]
    lappend menuList .pm.set
    $m add cascade -label $set -font $fontName -menu $pms
    foreach pp $typeTable {
	if {[lindex $pp 0] == $pos} {
	    # Now [lindex pp 1] has a list of all features of POS
	    foreach pa [lindex $pp 1] {
		set mi [menu .pm.set.$pa]
		lappend menuList .pm.set.$pa
		foreach ff $attrTable {
		    if {[lindex $ff 0] == $pa} {
			# Now [lindex $ff 1] has a list of values of feature
			foreach ff1 [lindex $ff 1] {
			    $mi add command -label $ff1 -command \
					[list setRvalue $i $t $pa $ff1]
			}
		    }
		}
		$pms add cascade -label $pa -menu $mi
	    }
	}
    }
    # create change POS menu
    set pmc [menu .pm.change]
    lappend menuList $pmc
    $m add cascade -label $changePOS -font $fontName -menu $pmc
    foreach pp $typeTable {
	set pa [lindex $pp 0]
	if {$pa != $pos} {
	    $pmc add command -label $pa -command [list changeRpos $i $t $pa]
	}
    }
    tk_popup $m %X %Y
}

proc addRvalue {position str feature value} {
    global menuList undoList currentUntouched

    foreach m $menuList {
	catch {destroy $m}
    }
    catch {destroy .pm}
#    puts stderr [format "position=%d, str=%s, feature=%s, value=%s" $position $str \
#	    $feature $value]
    set undoList [linsert $undoList 0 [list "c" $position $str \
	    $currentUntouched]]
    if {[string first "$feature=" $str] >= 0} {
	# feature found, append with a vertical bar
	set i [expr [string first "$feature=" $str] + \
		[string length $feature] + 1]
	set ff [string range $str 0 [expr $i - 1]]
	set tt [string range $str $i [string length $str]]
	regexp -indices {^[A-Za-z0-9_\|]+} $tt mv
	set f2 [string range $tt 0 [lindex $mv 1]]
	set str [format "%s%s|%s%s" $ff $f2 $value [string range $tt \
		[expr [lindex $mv 1] + 1] [string length $tt]]]
    } else {
	# feature not found, insert after left bracket with feature=
	set i [string first "\[" $str]
	set f [string range $str 0 $i]
	set l [string range $str [expr $i + 1] [string length $str]]
	set str [format "%s%s=%s %s" $f $feature $value $l]
    }
    .fr.desc.text delete $position
    .fr.desc.text insert $position $str
    .fr.desc.text activate $position
    .fr.desc.text selection set $position
    set currentUntouched 0
}

proc deleteRvalue {position str feature value} {
    global menuList undoList currentUntouched

    foreach m $menuList {
	catch {destroy $m}
    }
    catch {destroy .pm}
#    puts stderr [format "position=%d, str=%s, feature=%s, value=%s" $position $str \
#	    $feature $value]
    set undoList [linsert $undoList 0 [list "c" $position $str \
	    $currentUntouched]]
    if {[string first "$feature=" $str] >= 0} {
	# feature found, look for the value
	set i [expr [string first "$feature=" $str] + \
		[string length $feature] + 1]
	set l [string range $str $i [string length $str]]
	regexp -indices {^[A-Za-z0-9_\|]+} $l mv
	set fv [split [string range $l [lindex $mv 0] [lindex $mv 1]] "\|"]
	set len [llength $fv]
	if {$len == 1} {
	    # There is only one feature value, delete it with feature=
	    set leftstring [string trimright [string range $str 0 \
		    [expr $i - [string length $feature] - 2]]]
	    set rightstring [string trimleft [string range $l \
		    [expr [lindex $mv 1] + 1] [string length $l]]]
	    if {[string range $leftstring end end] == "\[" || \
		    [string range $rightstring 0 0] == "\]"} {
		set str [format "%s%s" $leftstring $rightstring]
	    } else {
		set str [format "%s %s" $leftstring $rightstring]
	    }
	} else {
	    # The value is one of a few present
	    for {set j 0} {$j < [llength $fv]} {incr j} {
		if {[lindex $fv $j] == $value} {
		    break;
		}
	    }
	    incr i -1
	    if {$j == 0} {
		# The feature value is the first, delete with the following |
		set str [format "%s%s" [string range $str 0 $i] \
			[string range $l [expr [string length $value] + 1] \
			[string length $l]]]
	    } else {
		# Delete the feature with the preceeding vertical bar
		set i [expr $i + [string length [lindex $fv 0]]]
		for {set k 1} {$k < $j} {incr k} {
		    set i [expr $i + [string length [lindex $fv $k]] + 1]
		}
		set str [format "%s%s" [string range $str 0 $i] \
			[string range $str [expr $i + [string length \
			$value] + 2] [string length $str]]]
	    }
	}
    } else {
	puts stderr "Error in description!"
    }
    .fr.desc.text delete $position
    .fr.desc.text insert $position $str
    .fr.desc.text activate $position
    .fr.desc.text selection set $position
    set currentUntouched 0
}

proc setRvalue  {position str feature value} {
    global menuList undoList currentUntouched

    foreach m $menuList {
	catch {destroy $m}
    }
    catch {destroy .pm}
#    puts stderr [format "position=%d, str=%s, feature=%s, value=%s" $position $str \
#	    $feature $value]
    set undoList [linsert $undoList 0 [list "c" $position $str \
	    $currentUntouched]]
    if {[string first "$feature=" $str] >= 0} {
	set i [expr [string first "$feature=" $str] + \
		[string length $feature] + 1]
	set l [string range $str $i [string length $str]]
	regexp -indices {^[A-Za-z0-9_\|]+} $l mv
	set l [string range $l [expr [lindex $mv 1] + 1] [string length $l]]
	set f [string range $str 0 [expr $i - 1]]
	set str [format "%s%s%s" $f $value $l]
    } else {
	# Insert the string right after the opening bracket
	set i [string first "\[" $str]
	set f [string range $str 0 $i]
	set l [string range $str [expr $i + 1] [string length $str]]
	set str [format "%s%s=%s %s" $f $feature $value $l]
    }
    .fr.desc.text delete $position
    .fr.desc.text insert $position $str
    .fr.desc.text activate $position
    .fr.desc.text selection set $position
    set currentUntouched 0
}


proc changeRpos {position str pos} {
    global menuList undoList currentUntouched

    foreach m $menuList {
	catch {destroy $m}
    }
    catch {destroy .pm}
#    puts stderr [format "position=%d, str=%s, pos=%s" $position $str $pos]
    set undoList [linsert $undoList 0 [list "c" $position $str \
	    $currentUntouched]]
    set i [expr [string first "\]" $str] + 1]
    set str [format "%s\[\]%s" $pos \
	    [string range $str $i [string length $str]]]
    .fr.desc.text delete $position
    .fr.desc.text insert $position $str
    .fr.desc.text activate $position
    .fr.desc.text selection set $position
    set currentUntouched 0
}

focus .fr.wordform.text

proc UnbindButts {} {
    global exitShort fileShort custShort mmorphShort saveShort helpShort
    global matchShort undoShort loadShort removeShort editShort replShort

    bind . $exitShort {}
    bind . $fileShort {}
    bind . $custShort {}
    bind . $mmorphShort {}
    bind . $saveShort {}
    bind . $helpShort {}
    bind . $matchShort {}
    bind . $saveShort {}
    bind . $helpShort {}
    bind . $loadShort {}
    bind . $undoShort {}
    bind . $removeShort {}
    bind . $editShort {}
    bind . $replShort {}
    bind .fr.wordform.text $exitShort {}
    bind .fr.wordform.text $fileShort {}
    bind .fr.wordform.text $custShort {}
    bind .fr.wordform.text $mmorphShort {}
    bind .fr.wordform.text $saveShort {}
    bind .fr.wordform.text $helpShort {}
    bind .fr.wordform.text $matchShort {}
    bind .fr.wordform.text $saveShort {}
    bind .fr.wordform.text $helpShort {}
    bind .fr.wordform.text $loadShort {}
    bind .fr.wordform.text $undoShort {}
    bind .fr.wordform.text $removeShort {}
    bind .fr.wordform.text $editShort {}
    bind .fr.wordform.text $replShort {}
    bind .fr.desc.text $exitShort {}
    bind .fr.desc.text $fileShort {}
    bind .fr.desc.text $custShort {}
    bind .fr.desc.text $mmorphShort {}
    bind .fr.desc.text $saveShort {}
    bind .fr.desc.text $helpShort {}
    bind .fr.desc.text $matchShort {}
    bind .fr.desc.text $saveShort {}
    bind .fr.desc.text $helpShort {}
    bind .fr.desc.text $loadShort {}
    bind .fr.desc.text $undoShort {}
    bind .fr.desc.text $removeShort {}
    bind .fr.desc.text $replShort {}
}

proc RewriteStrings {} {
    global toolName fileName fileU cust custU help helpU openGu openGuU
    global saveDesc saveDescU tExit tExitU lang langU font fontU word
    global mmorphOut descr saveButt saveButtU exitButt exitButtU
    global exitShort saveShort mmorphShort fileShort custShort helpShort
    global mmorphButt mmorphButtU fontName wordOpen wordOpenU editButt
    global editButtU wordRemove wordRemoveU saveRemoves
    global saveRAll sortattLab mmorphLab morphdescLab guessSaveLab
    global undoButt undoButtU simp no yes matchButt matchButtU matchShort
    global removeShort loadShort undoShort editShort replaceButt replaceButtU
    global replShort printStats printStatsU

    wm title . $toolName
    .fr.wordform.lab configure -text $word
    .fr.wordbutt.open configure -text $wordOpen -underline $wordOpenU
    .fr.wordbutt.remove configure -text $wordRemove -underline $wordRemoveU
    .fr.mmorph.lab configure -text $mmorphOut
    .fr.desc.lab configure -text $descr
    .fr.descbutt.mmorph configure -text $mmorphButt -underline $mmorphButtU
    .fr.descbutt.save configure -text $saveButt -underline $saveButtU
    .fr.descbutt.edit configure -text $editButt -underline $editButtU
    .fr.descbutt.undo configure -text $undoButt -underline $undoButtU
    .fr.descbutt.srlab configure -text $saveRemoves
    .fr.descbutt.rba configure -text $saveRAll
    .fr.butt.match configure -text $matchButt -underline $matchButtU
    .fr.butt.exit configure -text $tExit -underline $tExitU
    .fr.butt.slab configure -text $simp
    .fr.butt.s0 configure -text $no
    .fr.butt.s1 configure -text $yes
    .fr.butt.repl configure -text $replaceButt -underline $replaceButtU

    bind . $exitShort {exitProg}
    bind . $fileShort {.menubar.file.menu post %x %y}
    bind . $custShort {.menubar.customize.menu post %x %y}
    bind . $mmorphShort {GenMmorph}
    bind . $helpShort {DispHelp}
    bind . $matchShort {matchMmorph}
    bind . $removeShort {removeWord}
    bind . $saveShort {saveOneDesc}
    bind . $loadShort {OpenFile}
    bind . $undoShort {undoOp}
    bind . $editShort {EditPopup}
    bind . $replShort {replaceMmorph}
    bind .fr.wordform.text $exitShort {exitProg}
    bind .fr.wordform.text $fileShort {.menubar.file.menu post %x %y}
    bind .fr.wordform.text $custShort {.menubar.customize.menu post %x %y}
    bind .fr.wordform.text $mmorphShort {GenMmorph}
    bind .fr.wordform.text $helpShort {DispHelp}
    bind .fr.wordform.text $matchShort {matchMmorph}
    bind .fr.wordform.text $removeShort {removeWord}
    bind .fr.wordform.text $saveShort {saveOneDesc}
    bind .fr.wordform.text $loadShort {OpenFile}
    bind .fr.wordform.text $undoShort {undoOp}
    bind .fr.wordform.text $editShort {EditPopup}
    bind .fr.wordform.text $replShort {replaceMmorph}
    bind .fr.desc.text $exitShort {exitProg}
    bind .fr.desc.text $fileShort {.menubar.file.menu post %x %y}
    bind .fr.desc.text $custShort {.menubar.customize.menu post %x %y}
    bind .fr.desc.text $mmorphShort {GenMmorph}
    bind .fr.desc.text $helpShort {DispHelp}
    bind .fr.desc.text $matchShort {matchMmorph}
    bind .fr.desc.text $removeShort {removeWord}
    bind .fr.desc.text $saveShort {saveOneDesc}
    bind .fr.desc.text $loadShort {OpenFile}
    bind .fr.desc.text $undoShort {undoOp}
    bind .fr.desc.text $editShort {editPopup}
    bind .fr.desc.text $replShort {replaceMmorph}

    .menubar.file configure -text $fileName -underline $fileU
    .menubar.customize configure -text $cust -underline $custU
    .menubar.help configure -text $help -underline $helpU
    .menubar.file.menu entryconfigure 1 -label $openGu -underline $openGuU
    .menubar.file.menu entryconfigure 2 -label $saveDesc -underline $saveDescU
    .menubar.file.menu entryconfigure 3 -label $printStats \
	    -underline $printStatsU
    .menubar.file.menu entryconfigure 4 -label $tExit -underline $tExitU
    .menubar.customize.menu entryconfigure 1 -label $lang -underline $langU
    .menubar.customize.menu entryconfigure 2 -label $font -underline $fontU
    .menubar.customize.menu entryconfigure 3 -label $sortattLab
    .menubar.customize.menu entryconfigure 4 -label $mmorphLab
    .menubar.customize.menu entryconfigure 5 -label $morphdescLab
    .menubar.customize.menu entryconfigure 6 -label $guessSaveLab
    .menubar.help.menu entryconfigure 1 -label $help -underline $helpU

    .fr.wordform.lab configure -font $fontName
    .fr.wordbutt.remove configure -font $fontName
    .fr.mmorph.lab configure -font $fontName
    .fr.desc.lab configure -font $fontName
    .fr.descbutt.srlab configure -font $fontName
    .fr.descbutt.rba configure -font $fontName
    .fr.butt.slab configure -font $fontName
    .fr.butt.match configure -font $fontName
    .fr.butt.repl configure -font $fontName

    .menubar.file configure -font $fontName
    .menubar.customize configure -font $fontName
    .menubar.help configure -font $fontName
    .menubar.file.menu entryconfigure 1 -font $fontName
    .menubar.file.menu entryconfigure 2 -font $fontName
    .menubar.file.menu entryconfigure 3 -font $fontName
    .menubar.file.menu entryconfigure 4 -font $fontName
    .menubar.customize.menu entryconfigure 1 -font $fontName
    .menubar.customize.menu entryconfigure 2 -font $fontName
    .menubar.customize.menu entryconfigure 3 -font $fontName
    .menubar.customize.menu entryconfigure 4 -font $fontName
    .menubar.customize.menu entryconfigure 5 -font $fontName
    .menubar.customize.menu entryconfigure 6 -font $fontName
    .menubar.help.menu entryconfigure 1 -font $fontName

    .fr.descbutt.mmorph configure -font $fontName
    .fr.descbutt.save configure -font $fontName
    .fr.descbutt.undo configure -font $fontName
    .fr.butt.exit configure -font $fontName

#    wm configure -font $fontName
}

proc setLabels {language} {
    UnbindButts
    if {$language == "English"} {
	setDefaultNames
    } else {
	setNames $language
    }
    RewriteStrings
}

if {$parLabels != ""} {
    setLabels $parLabels
}
if {$readFile != ""} {
    ReadFile $readFile
}

proc FontPopup {} {
    global textFont fontName font

    toplevel .fpop -width 10c -height 4c

    grab .fpop
    wm title .fpop $font


    label .fpop.lab -font $fontName -text $font
    entry .fpop.en -width 40 -relief sunken -textvariable textFont
    pack .fpop.lab -side left
    pack .fpop.en -side left
    bind .fpop <Return> {ClosePop}
    focus .fpop.en
}


proc ClosePop {} {
    global textFont

    .fr.wordform.text configure -font $textFont
    .fr.mmorph.text configure -font $textFont
    .fr.desc.text configure -font $textFont
    destroy .fpop
}


proc EditPopup {} {

    global fontName oldDesc newDesc cancel 
    global descNo textFont currentUntouched

    set descNo [.fr.desc.text curselection]
    if {[llength $descNo] == 1} {
	set oldDesc [.fr.desc.text get $descNo]
	set newDesc $oldDesc
	toplevel .epop -width 60c -height 6c

	grab .epop
	wm title .epop "Correct" 

	frame .epop.fr
	pack .epop.fr -side top -anchor n
	label .epop.fr.lab -font $fontName -text "Desc:"
	entry .epop.fr.en -width 80 -font $textFont -relief sunken \
		-textvariable newDesc
	pack .epop.fr.lab -side left -anchor w
	pack .epop.fr.en -side left -expand t -anchor w
	frame .epop.butt
	pack .epop.butt -side bottom -anchor s
	button .epop.butt.ok -text "OK" -command closeEpop
	button .epop.butt.canc -text $cancel -command cancelPop
	pack .epop.butt.ok -side left -anchor w
	pack .epop.butt.canc -side right -anchor e
	bind .epop <Return> {closeEpop}
#	bind .epop <Escape> {cancelPop}
	focus .epop
	set currentUntouched 0
    }
}

proc closeEpop {} {
    global newDesc descNo undoList currentUntouched

    set undoList [linsert $undoList 0 [list "c" $descNo \
	    [.fr.desc.text get $descNo] $currentUntouched]]
    .fr.desc.text delete $descNo
    .fr.desc.text insert $descNo $newDesc
    destroy .epop
    .fr.desc.text selection set $descNo
    .fr.desc.text activate $descNo
}

proc cancelPop {} {

    destroy .epop
    .fr.desc.text selection set [.fr.desc.text index active]
}

proc DispHelp {} {
    global help fontName helpFile globalLanguage encChar

    toplevel .hpop -width 60 -height 20
    grab .hpop
    wm title .hpop $help
    wm minsize .hpop 1 1

    button .hpop.ok -text OK -command {destroy .hpop}
    pack .hpop.ok -in .hpop -side bottom

    text .hpop.text -font $fontName -yscrollcommand ".hpop.ys set"
    scrollbar .hpop.ys -command ".hpop.text yview"
    pack .hpop.text -in .hpop -side left -fill both -expand 1
    pack .hpop.ys -in .hpop -side right -fill y

    set f1 [open $helpFile r]
    set i 1
    while {![eof $f1]} {
	set li [gets $f1]
	if {[string range $li 0 0] == $encChar} {
	    #fconfigure $f1 -encoding [string range $li 1 end]
	} else {
	    .hpop.text insert end $li
	    .hpop.text insert end "\n"
	    if {[regexp "^\\*" $li]} {
		.hpop.text tag add lang $i.0 $i.end
	    }
	    if {[regexp "^\[0-9\]+\\. " $li]} {
		.hpop.text tag add section $i.0 $i.end
	    }
	    if {[regexp "^\\ \[0-9\]+\\. " $li]} {
		.hpop.text tag add toc $i.0 $i.end
	    }
	    incr i 1
	}
    }
    close $f1
    .hpop.text tag configure section -foreground red
    .hpop.text tag configure lang -foreground [.hpop.text cget -background]
    .hpop.text tag configure toc -foreground blue
    set l ""
    set l [.hpop.text search -regexp "^\\*$globalLanguage" 1.0]
    if {$l != ""} {
	.hpop.text see $l
    }
    bind .hpop <Next> {.hpop.text yview scroll 1 pages}
    bind .hpop <Prior> {.hpop.text yview scroll -1 pages}
    .hpop.text tag bind toc <Button> {goLink %x %y}
}

proc goLink {x y} {
    global globalLanguage

    set i [.hpop.text index @$x,$y]
    set sect [.hpop.text get "$i linestart + 1 c" "$i lineend"]
    set l  [.hpop.text search -regexp "^$sect" \
	    [.hpop.text search -regexp "^\\*$globalLanguage" 1.0]]
    if {$l != ""} {
	.hpop.text see $l
    }
}

# saving descriptions in a file
proc saveDesc {} {
    global results resultsFile descSaved encoding

    set f1 [open $resultsFile w]
    #fconfigure $f1 -encoding $encoding
    foreach r $results {
	puts $f1 $r
    }
    close $f1
    set descSaved 1
}

# saving (choosing for later processing) one description
proc saveOneDesc {} {
    global results descSaved saver predictions preamble morphdesc mmorph
    global undoList currentUntouched firstCorrect anyCorrect noSaved
    global precision encoding

    set descSaved 0
    set cs [.fr.desc.text curselection]
    set description [.fr.desc.text get $cs]
    lappend results $description
    incr noSaved
    if {$saver == 1} {
	set cs [.fr.wordform.text index active]
	set undoList [linsert $undoList 0 \
		[list "s" [list  $cs [.fr.wordform.text get $cs]]]]
	.fr.wordform.text delete $cs
	if {$currentUntouched == 1} {
	    incr anyCorrect
	    if {$cs == 1} {
		incr firstCorrect
	    }
	    if {[.fr.desc.text index end] > 0} {
		set precision [expr $precision + [expr 1 / \
			[.fr.desc.text index end]]]
	    }
	}
    } elseif {$saver == 2} {
	exec cp $preamble $morphdesc
	set f1 [open $morphdesc a]
	#fconfigure $f1 -encoding $encoding
	puts $f1 $description
	close $f1
	exec cat /dev/null | $mmorph -c -m $morphdesc > /dev/null
	set mm "mm"
	set kupa "{print substr(\$1,2,length(\$1)-2);}"
	exec $mmorph -q -m $morphdesc | awk $kupa | sort -u > $mm
	# Now the file mm contains all words generated by $description
	set f2 [open $mm r]
	#fconfigure $f2 -encoding $encoding
	while {![eof $f2]} {
	    set w [gets $f2]
	    lappend wlist $w
	}
	set itemList {}
	for {set i 0} {$i < [.fr.wordform.text index end] } \
		{incr i} {
	    set cs [.fr.wordform.text get $i]
	    for {set it 0} {$it < [llength $wlist]} {incr it} {
		if {$cs == [lindex $wlist $it]} {
		    set itemList [linsert $itemList 0 \
			    [list $i [.fr.wordform.text get $i]]]
		    if {$currentUntouched == 1} {
#			puts stderr [format "for WORD: %s" [.fr.wordform.text get $i]]
#			puts stderr "preds are $predictions([.fr.wordform.text get $i])"
			set pred [mySplit $predictions([.fr.wordform.text get \
				$i]) ", "]
			for {set k 0} {$k < [llength $pred]} {incr k} {
#			    puts stderr [format "$k-th desc is %s, description is %s" [lindex $pred $k] $description]
#			    puts stderr "pred is $pred"
			    if {[lindex $pred $k] == $description} {
				incr anyCorrect
#				puts stderr "anyCorrect is $anyCorrect"
				if {$k == 0} {
				    incr firstCorrect
#				    puts stderr "firstCorrect is $firstCorrect"
				}
				set precision [expr $precision + \
					[expr 1.0 / [llength $pred]]]
#				puts stderr [format "1/%5.2f=%5.2f" [llength $pred] $precision]
#				puts stderr "precision now is $precision"
				break;
			    }
			}
		    }
		    .fr.wordform.text delete $i
		    incr i -1
		    break
		}
	    }
	}
	set undoList [linsert $undoList 0 [list "s" $itemList] \
		$currentUntouched]
	.fr.desc.text configure -selectbackground gray
    }
}

# code from Tcl and the Tk toolkit by John K. Ousterhout
proc dialog {w title text bitmap default args} {
    global button fontName

    # 1. Create the top-level window and divide it into top
    # and bottom parts.

    toplevel $w -class Dialog
    wm title $w $title
    wm iconname $w Dialog
    frame $w.top -relief raised -bd 1
    pack $w.top -side top -fill both
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both

    # 2. Fill the top part with the bitmap and message.

    message $w.top.msg -width 3i -text $text -font $fontName
    pack $w.top.msg -side right -expand 1 -fill both -padx 3m -pady 3m
    if {$bitmap != ""} {
	label $w.top.bitmap -bitmap $bitmap
	pack $w.top.bitmap -side left -padx 3m -pady 3m
    }

    # 3. Create a row of buttons at the bottom of the dialog

    set i 0
    foreach but $args {
	button $w.bot.button$i -text $but -command "set button $i"
	if {$i == $default} {
	    frame $w.bot.default -relief sunken -bd 1
	    raise $w.bot.button$i
	    pack $w.bot.default -side left -expand 1 -padx 3m -pady 2m
	    pack $w.bot.button$i -in $w.bot.default\
		    -side left -padx 2m -pady 2m -ipadx 2m -ipady 1m
	} else {
	    pack $w.bot.button$i -side left -expand 1\
		    -padx 3m -pady 3m -ipadx 2m -ipady 1m
	}
	incr i
    }

    # 4. Set up a binding for <RETURN>, if there's a default,
    # set a grab, and claim the focus too

    if {$default >= 0} {
	bind $w <Return> "$w.bot.button$default flash; \
		set button $default"
    }
    set oldFocus {focus}
    grab set $w
    focus $w

    # 5. Wait for the user to respond, then restore the focus
    # and return the index of the selected button.

    tkwait variable button
    destroy $w
    catch {focus $oldFocus}
    catch {
	bind $w <Destroy> {}
	destroy $w
    }
    return $button
}

proc exitProg {} {
    global descSaved dnst dns saveButtMsg dontSaveButtMsg guessSave predictions
    global encoding

    if {!$descSaved} {
	set s [dialog .d $dnst $dns warning 0 $saveButtMsg $dontSaveButtMsg]
	if {$s} {
	} else {
	    saveDesc
	}
    }
    set f1 [open $guessSave w]
    #fconfigure $f1 -encoding $encoding
    for {set i 0} {$i < [.fr.wordform.text index end]} \
	    {incr i} {
	set cs [.fr.wordform.text get $i]
	set ds $predictions($cs)
	puts $f1 [format "%s: %s" $cs $ds]
    }
    close $f1
    printStatistics
    exit
}

proc editStr {strName strVar} {
    global cancel $strVar strValue fontName textFont

    toplevel .cpop -width 60 -height 20
    grab .cpop
    wm title .cpop $strName
    set strValue [expr [format "$%s" $strVar]]

    entry .cpop.en -width 80 -relief sunken -font textFont -textvariable strValue
    pack .cpop.en -side top -anchor n
    
    frame .cpop.butt
    pack .cpop.butt -side bottom -anchor s
    button .cpop.butt.ok -text "OK" -command [list closeCPop $strVar]
    button .cpop.butt.canc -text $cancel -command cancelCPop
    pack .cpop.butt.ok -side left -anchor w
    pack .cpop.butt.canc -side right -anchor e
    focus .cpop
    bind .cpop.butt.ok <Return> [list closeCPop $strVar]
    bind .cpop <Return> [list closeCPop $strVar]
    bind .cpop.butt.canc <Return> {cancelCPop}
    bind .cpop <Escape> {cancelCPop}
}

proc closeCPop {strVar} {
    global $strVar strValue

    set $strVar $strValue
    destroy .cpop
}


proc cancelCPop {} {

    destroy .cpop
}

proc removeWord {} {
    global undoList deleted

    if {[llength [.fr.wordform.text curselection]] != 0} {
	set undoList [linsert $undoList 0 [list "r" \
		[.fr.wordform.text curselection] \
		[.fr.wordform.text get  [.fr.wordform.text curselection]]]]
	.fr.wordform.text delete [.fr.wordform.text curselection]
	incr deleted
    }
    .fr.wordform.text selection set [.fr.wordform.text index active]
    ShowDesc
}

proc undoOp {} {
    global undoList currentUntouched deleted anyCorrect firstCorrect noSaved
    global results

    if {[llength $undoList] > 0} {
	set undoItem [lindex $undoList 0]
	if {[lindex $undoItem 0] == "r"} {
	    .fr.wordform.text insert [lindex $undoItem 1] [lindex $undoItem 2]
	    .fr.wordform.text selection set [lindex $undoItem 1]
	    set undoList [lrange $undoList 1 [llength $undoList]]
	    incr deleted -1
	} elseif {[lindex $undoItem 0] == "c"} {
	    .fr.desc.text delete [lindex $undoItem 1]
	    .fr.desc.text insert [lindex $undoItem 1] [lindex $undoItem 2]
	    .fr.desc.text selection set [lindex $undoItem 1]
	    .fr.desc.text activate [lindex $undoItem 1]
	    set currentUntouched [lindex $undoItem 3]
	    set undoList [lrange $undoList 1 [llength $undoList]]
	} elseif {[lindex $undoItem 0] == "s"} {
	    set saveList [lindex $undoItem 1]
	    set currentUntouched [lindex $undoItem 2]
	    while {[llength $saveList] > 0} {
		set saveItem [lindex $saveList 0]
		.fr.wordform.text insert [lindex $saveItem 0] \
			[lindex $saveItem 1]
		if {$currentUntouched == 1} {
		    incr anyCorrect -1
		    if {[lindex $saveItem 0] == 0} {
			incr firstCorrect -1
		    }
		    set precision [expr $precision - [expr 1 / \
			    [llength [mySplit \
			    $predictions([lindex $saveItem 1]) ", "]]]]
		}
		set saveList [lrange $saveList 1 [llength $saveList]]
	    }
	    set undoList [lrange $undoList 1 [llength $undoList]]
	    # puts stderr "results before: $results"
	    set results [lrange $results 0 [expr [llength $results] - 2]]
	    # puts stderr "results after: $results"
	    ShowDesc
	    incr noSaved -1
	}
    }
}

proc findAttributtes {} {
    # Format of attrTable is:
    # {{aName1 {a11 a12...}} {aName2 {a21 a22...}}...}
    global preamble attrTable typeTable encoding

    # Read attributes from the preamble file and put them into attrTab
    set commentchar ";"
    set inside 0
    # aName is attribute (feature) name
    set aName ""
    set f1 [open $preamble r]
    #fconfigure $f1 -encoding $encoding
    set attrTable {}
    set typeTable {}
    while {![eof $f1]} {
	set pline [gets $f1]
	if {[string range $pline 0 0] != $commentchar} {
	    set commentIndex [string first $commentchar $pline]
	    if {$commentIndex != -1} {
		set pline [string range $pline 0 [expr $commentIndex - 1]]
	    }
	    set pline [string trim $pline]
	    if {[regexp {@ *Attributes} $pline]} {
		set inside 1
		set i [string first "Attributes" $pline]
		set pline [string range $pline [expr $i + 10] \
			[string length $pline]]
	    } elseif {[regexp {@ *Types} $pline]} {
		set inside 2
		set i [string first "Types" $pline]
		set pline [string range $pline [expr $i + 10] \
			[string length $pline]]
	    } elseif {[regexp {@} $pline]} {
		if {$inside == 1 && $aName != ""} {
		    lappend attrTable [list $aName $aList]
		} elseif {$inside == 1 && $aName != ""} {
		    lappend typeTable [list $aName $aList]
		}
		set inside 0
		set aName ""
		set aList {}
	    }
	    if {$inside == 1} {
		while {[string length $pline] > 0} {
		    if {[regexp {^[A-Za-z_0-9]+[ 	]*:} $pline]} {
			if {$aName != ""} {
			    lappend attrTable [list $aName $aList]
			}
			set colonIndex [string first ":" $pline]
			set aName [string range $pline 0 \
				[expr $colonIndex - 1]]
			set aName [string trim $aName]
			set aList {}
			set pline [string range $pline [expr $colonIndex + 1]\
				[string length $pline]]
		    } elseif {[regexp -indices {^[A-Za-z_0-9]+} $pline mv]} {
			lappend aList [string range $pline [lindex $mv 0] \
				[lindex $mv 1]]
			set pline [string range $pline \
				[expr [lindex $mv 1] + 1] \
				[string length $pline]]
		    } else {
			puts stderr [format "shit: %s" $pline]
			set pline ""
		    }
		    set pline [string trim $pline]
		}
	    } elseif {$inside == 2} {
		set pline [string trim $pline]
		while {[string length $pline] > 0} {
		    if {[regexp {^[A-Za-z_0-9]+[ 	]*:} $pline]} {
			if {$aName != ""} {
			    lappend typeTable [list $aName $aList]
			}
			set colonIndex [string first ":" $pline]
			set aName [string range $pline 0 \
				[expr $colonIndex - 1]]
			set aName [string trim $aName]
			set aList {}
			set pline [string range $pline [expr $colonIndex + 1]\
				[string length $pline]]
		    } elseif {[regexp -indices {^[A-Za-z_0-9]+} $pline mv]} {
			lappend aList [string range $pline [lindex $mv 0] \
				[lindex $mv 1]]
			set pline [string range $pline \
				[expr [lindex $mv 1] + 1] \
				[string length $pline]]
		    } elseif {[string compare [string range $pline 0 1] "|"]} {
			set pline [string range $pline 1 \
				[string length $pline]]
		    } else {
			puts stderr [format "shit: %s" $pline]
			set pline ""
		    }
		    set pline [string trim $pline]
		}
	    }
	}
    }
    close $f1
}

proc readParafile {} {
    global  paradigmFile paraList

    # Read paradigm file
    set oldaName ""
    set paraList {}
    set f1 [open $paradigmFile r]
    if {![eof $f1]} {
	set pline [gets $f1]
	set commentchar [string range $pline 0 0]
    }
    while {![eof $f1]} {
	set pline [gets $f1]
	set pline [string trim $pline]
	if {[string range $pline 0 0] != $commentchar && \
		[string length $pline] != 0} {
	    if {[regexp -indices {^[A-Za-z0-9_]+} $pline mv]} {
		set aName [string range $pline 0 [lindex $mv 1]]
		set pline [string range $pline [expr [lindex $mv 1] + 1]\
			[string length $pline]]
		set pline [string trim $pline]
		if {$aName != $oldaName} {
		    if {$oldaName != ""} {
			lappend paraList [list $oldaName $aList]
		    }
		    set aList {}
		    set oldaName $aName
		}
	    } else {
		puts stderr "Error in paradigm file - no POS"
		puts stderr $pline
		break
	    }
	    if {[regexp -indices {^[A-Za-z0-9_=\|\.\(\)]+} $pline mv]} {
		set condition [string range $pline 0 [lindex $mv 1]]
		set pline [string range $pline [expr [lindex $mv 1] + 1] \
			[string length $pline]]
		set pline [string trim $pline]
	    } else {
		puts stderr "Error in paradigm file - no condition"
		puts stderr $pline
		break
	    }
	    lappend aList [list $condition [split $pline ","]]
	}
    }
    lappend paraList [list $oldaName $aList]
    close $f1
}

if {$paradigmFile != ""} {
    findAttributtes
    readParafile
}

proc matchMmorph {} {
    global attrTable paraList mmstrings preamble morphdesc mmorph alternatives
    global sortatt simplify encoding

    set lastactive [.fr.desc.text index active]
    # Store current mmorph output in $current
    set atts {}
    if {[llength [.fr.desc.text curselection]] == 1 && \
	    [llength [.fr.mmorph.text get 0.0 end]] > 0} {
	set current {}
	for {set i 1} {0 < [string length [.fr.mmorph.text get $i.0 $i.end]]} \
		{incr i} {
	    lappend current [.fr.mmorph.text get $i.0 $i.end]
	}
	set current [lsort $current]

	# Look at the current line in descriptions
	# Find what the POS tag is, and see if the conditions match
	set descLine [.fr.desc.text get [.fr.desc.text curselection]]
	set i [string first "\[" $descLine]
	set pos [string trim [string range $descLine 0 [expr $i - 1]]]
	for {set i 0} {$i < [llength $paraList]} {incr i} {
	    set l [lindex $paraList $i]
	    if {[lindex $l 0] == $pos} {
#		puts stderr [format "length of $l is %d" [llength $l]]
		for {set j 0} {$j < [llength [lindex $l 1]]} {incr j} {
		    set r [lindex [lindex [lindex $l 1] $j] 0]
#		    puts stderr "Looking for $r in $descLine"
		    if {[regexp "$r" $descLine]} {
			set atts [lindex [lindex [lindex $l 1] $j] 1]
			break;
		    }
		}
	    }
	    if {[llength $atts] > 0} {
		break
	    }
	}
    } else {
	if {[llength [.fr.desc.text curselection]] != 1} {
#	    puts stderr "Selection not unique"
	} elseif {[llength [.fr.mmorph.text get 0.0 end]] <= 0} {
	    puts stderr "Not enough mmorph output"
	}
    }

    # For each combination of values of each attribute, generate mmorph input
    set mmstrings {}
    if {$atts != {}} {genString $descLine $atts}

    # For every mmorph input, generate output, and compare it to $current
    set equal 0
    foreach m $mmstrings {
#	puts stderr [format "Generating for %s" $m]
	exec cp $preamble $morphdesc
	set f1 [open $morphdesc a]
	#fconfigure $f1 -encoding $encoding
	puts $f1 $m
	set mm  "mm"
	close $f1
	exec cat /dev/null | $mmorph -c -m $morphdesc > /dev/null
	if {$alternatives == 0} {
	    exec $mmorph -q -m $morphdesc | $sortatt > $mm
	} else {
	    exec $mmorph -q -m $morphdesc | $sortatt | $simplify > $mm
	}
	set f4 [open $mm r]
	#fconfigure $f4 -encoding $encoding
	set mo {}
	while {![eof $f4]} {
	    set mexp [gets $f4]
	    if {[string length $mexp] > 0} {
		lappend mo [list $mexp]
	    }
	}
	close $f4

	# Now compare both lists
	if {[llength $current] == [llength $mo]} {
	    set equal 1
	    set mo [lsort $mo]
	    for {set i 0} {$i < [llength $mo]} {incr i} {
		if {[lindex $current $i] != [lindex [lindex $mo $i] 0]} {
		    set equal 0
		    break
		}
	    }
	} else {
	}
	if {$equal == 1} {
	    break
	}
    }
    if {$equal == 1} {
	set i [.fr.desc.text curselection]
	.fr.desc.text delete $i
	.fr.desc.text insert $i $m
	.fr.desc.text selection set $i
    }
    .fr.desc.text activate $lastactive
    if {$equal == 1} {
	.fr.desc.text configure -selectbackground green
    }
    focus .fr.desc.text
}

proc genString {iString aList} {
    global attrTable mmstrings

#    puts stderr "genString called with $iString, and aList $aList"
    if {[llength $aList] == 0} {
	lappend mmstrings $iString
    } else {
	set att [lindex $aList 0]
	if {[string first "*" [lindex $aList 0]] > 0} {
	    set att [string range $att 0 [expr [string length $att] \
			    - 2]]
	}
	set i [string first $att $iString]
	if {$i >= 0} {
	    set first_part [string range $iString 0 \
		    [expr $i + [string length $att]]]
	    set last_part [string range $iString \
		    [expr $i + [string length $att] + 1] \
		    [string length $iString]]
#	    puts stderr "$att found in $iString"
#	    puts stderr "first is $first_part, last is $last_part"
	} else {
	    set i [string first "\[" $iString]
	    set first_part [format "%s%s=" [string range $iString 0 $i] $att]
	    set last_part [format " %s" [string range $iString [expr $i + 1] \
		    [string length $iString]]]
#	    puts stderr "$att not found in $iString"
#	    puts stderr "first is $first_part, last is $last_part"
	    for {set i 0} {$i < [llength $attrTable]} {incr i} {
		if {[string first "*" [lindex $aList 0]] > 0} {
		    if {[lindex [lindex $attrTable $i] 0] == $att} {
			genComb [lindex [lindex $attrTable $i] 1] \
				$first_part $last_part \
				[lrange $aList 1 [llength $aList]] 1 1
		    }
		} elseif {[lindex [lindex $attrTable $i] 0] == \
			$att} {
		    foreach a [lindex [lindex $attrTable $i] 1] {
			genString "$first_part$a$last_part" \
				[lrange $aList 1 [llength $aList]]
		    }
		}
	    }
	}
	if {[regexp -indices {^[A-Za-z0-9_\|]+} $last_part mv]} {
	    set last_part [string range $last_part [expr [lindex $mv 1] + 1] \
		    [string length $last_part]]
	    for {set i 0} {$i < [llength $attrTable]} {incr i} {
		if {[string first "*" [lindex $aList 0]] > 0} {
		    if {[lindex [lindex $attrTable $i] 0] == $att} {
			genComb [lindex [lindex $attrTable $i] 1] \
				$first_part $last_part \
				[lrange $aList 1 [llength $aList]] 1 1
		    }
		} elseif {[lindex [lindex $attrTable $i] 0] == \
			$att} {
		    foreach a [lindex [lindex $attrTable $i] 1] {
			genString "$first_part$a$last_part" \
				[lrange $aList 1 [llength $aList]]
		    }
		}
	    }
	}
    }
}

proc genComb {aList fString lString rList alwaysEmpty allIn} {

#    puts stderr "genComb(aList=$aList, fString=$fString, lString=$lString, rList=$rList, aE=$alwaysEmpty)"
    if {[llength $aList] == 0} {
	if {$allIn == 0} {
	    if {$alwaysEmpty == 0} {
		genString "$fString$lString" $rList
	    } else {
		if {[regexp -indices {[A-Za-z0-9_]+=} $fString mv]} {
		    set fString [string range $fString 0 [expr [lindex $mv 0] \
			    - 1]]
		    if {[string range $fString end end] != " "} {
			set lString [string trimleft $lString]
		    }
		    set fString [string trimright $fString]
		    genString "$fString$lString" $rList
		}
	    }
	}
    } else {
	genComb [lrange $aList 1 [llength $aList]] $fString $lString $rList \
		$alwaysEmpty 0
	if {$alwaysEmpty == 1} {
	    genComb [lrange $aList 1 [llength $aList]] \
		    [format "%s%s" $fString [lindex $aList 0]] $lString \
		    $rList 0 $allIn
	} else {
	    genComb [lrange $aList 1 [llength $aList]] \
		    [format "%s|%s" $fString [lindex $aList 0]] $lString \
		    $rList 0 $allIn
	}
    }
}

proc replaceMmorph {} {
    global replaceButt replLab1 replLab2 textFont replvar withVar cancel
    global fontName

    if {[llength [.fr.mmorph.text get 0.0 end]] > 0} {
	# There is some text in the mmorph output pane
	toplevel .replpop -width 60 -height 20
	grab .replpop
	wm title .replpop $replaceButt
	frame .replpop.r
	pack .replpop.r -side top
	label .replpop.r.lab1 -text $replLab1 -font $fontName
	pack .replpop.r.lab1 -side left
	set replvar ""
	entry .replpop.r.en1 -width 80 -relief sunken -font $textFont \
		-textvariable replvar
	pack .replpop.r.en1 -side left
	frame .replpop.w
	pack .replpop.w -side top
	label .replpop.w.lab2 -text $replLab2 -font $fontName
	pack .replpop.w.lab2 -side left
	set withVar ""
	entry .replpop.w.en2 -width 80 -relief sunken -font $textFont \
		-textvariable withVar
	pack .replpop.w.en2 -side left
	frame .replpop.butts
	pack .replpop.butts -side bottom
	button .replpop.butts.ok -text "OK" -command {closeRepl}
	pack .replpop.butts.ok -side left -anchor w
	button .replpop.butts.cancel -text $cancel -command {cancelRepl}
	pack .replpop.butts.cancel -side right -anchor e
	bind .replpop.r.en1 <Return> {focus .replpop.w.en2}
	bind .replpop <Escape> {cancelRepl}
	bind .replpop.r.en1 <Escape> {cancelRepl}
	bind .replpop.w.en2 <Escape> {cancelRepl}
	bind .replpop.w.en2 <Return> {closeRepl}
	bind .replpop.butts.ok <Return> {closeRepl}
	bind .replpop.butts.ok <Escape> {cancelRepl}
	bind .replpop.butts.cancel <Escape> {cancelRepl}
	bind .replpop.butts.ok <Escape> {cancelRepl}
    }
}

proc closeRepl {} {
    global replvar withVar

    destroy .replpop
    set l [string length $replvar]
    for {set i 1} {0 < [string length [.fr.mmorph.text get $i.0 $i.end]]} \
	    {incr i} {
	set current [.fr.mmorph.text get $i.0 $i.end]
	set j 0
	set s [string range $current $j [string length $current]]
	set k [string first $replvar $s]
	while {$k >= 0} {
	    set first [string range $current 0 [expr $k + $j - 1]]
	    set last [string range $current [expr $k + $j + $l] \
		    [string length $current]]
	    set current [format "%s%s%s" $first $withVar $last]
	    set j [expr $k + [string length $withVar]]
	    set s [string range $current $j [string length $current]]
	    set k [string first $replvar $s]
	}
	.fr.mmorph.text delete $i.0 $i.end
	.fr.mmorph.text insert $i.0 $current
    }
}

proc cancelRepl {} {
    destroy .replpop
}

proc printStatistics {} {
    global deleted firstCorrect anyCorrect precision totalEntries noSaved
    global perEntry

    set remaining [.fr.wordform.text index end]
    set processed [expr $totalEntries - $deleted - $remaining]
    puts stderr "deleted is $deleted, firstCorrect is $firstCorrect, anyCorrect is $anyCorrect, precision is $precision, totalEntries is $totalEntries, noSaved is $noSaved, perEntry is $perEntry, remaining is $remaining, processed is $processed"
    if {$processed > 0} {
	puts stderr [format "Simplified recall is %6.2f%%" \
		[expr 100.0 * "$anyCorrect.0" / $processed]]
	puts stderr [format "Percentage of first correct is %6.2f%%" \
		[expr 100.0 * "$firstCorrect.0" / "$processed.0"]]
	puts stderr [format "Precision is %6.2f%%" \
		[expr 100.0 * $precision / "$processed.0"]]
	puts stderr [format "Coverage is %6.2f%%" \
		[expr 100.0 * "$remaining.0" / $totalEntries]]
	puts stderr [format "Average %5.2f descriptions per word" $perEntry]
	puts stderr [format "Directly saved %6.2f%% of all processed entries" \
		[expr 100.0 * $noSaved / "$processed.0"]]
	puts stderr [format "%6.2f%% entries deleted (incorrect?)" \
		[expr 100.0 * "$deleted.0" / $totalEntries ]]
	puts stderr [format "%6.2f%% entries remain unprocessed" \
		[expr 100.0 * "$remaining.0" / $totalEntries ]]
    } else {
	puts stderr "No entries processed"
    }
}
