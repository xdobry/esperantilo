# Skipto por importado de Esperantilo al loka eldona datumbanko (version repository)

set prot [IDE::Transcript newBrowser]

set cdir [pwd]

$prot warning "La importilo por fontokodo de esperantilo estas lancxita"

if {![IDE::System isDatabase]} {
    $prot warning "Vi necas XOTclIDE lancxitan en DB modo (version control)"
    $prot warning "Legu la manlibron de XOTclIDE"
    error "Importo malsukcesis"
}
update idletasks

[IDE::DBPersistence set connection] execute "PRAGMA synchronous =  0;"

if {[Object isclass EsperantoBrowser]} {
    $prot warning "Esperantilo estas jam en sistemo"
    error "Importo malsukcesis"
}

package require xotcl::comm::httpd

set comps [list EspTeknikajIloj EspBazaLingvo EspSintaksaAnalizo EspTradukilo EsperantoEdit EspTradukaVortaro EspAnalizoj EspTradukadoBazo EspTradukaVortaroGUI]

set fontoDosiero [pwd]

foreach f [glob -directory $fontoDosiero *.xotcl] {
     set f [file rootname [file tail $f]]
     if {$f eq "IDEBaseGUI" || $f eq "radikoj" || $f eq "EspPolaTradukilo" || $f eq "REVOmetakit" || $f eq "Esperantilo" || $f eq "TMServilo" || $f eq "IDEErrorReporter"} {
         continue
     }
     if {[lsearch $comps $f]<0} {
	 lappend comps $f
     }
}

# importu komponentoj de fonto al XOTclIDE komponento

encoding system utf-8
foreach c $comps {
    IDE::Component importCompsFromFile [file join $fontoDosiero $c.xotcl]
}
IDE::System signalComponentsChanged


$prot warning "Mi kopias vortaron kaj radikojn al aktuala dosierujo $cdir"
update idletasks

# importo kompoentoj al Version Control

foreach c $comps {
    set cobj [IDE::Component getCompObjectForNameIfExist $c]
    if {$cobj eq ""} {
        $prot log "komponento $c ne trovita"
        error "Importo malsukcesis"
    }
    IDE::ComponentPersistence importComponent $c
    foreach o [concat [$cobj getClasses] [$cobj getObjects] [$cobj getProcsGroupsObjects]]  {
	[$o getDescription] versionEdition
    }
    $cobj versionEdition
}

# kreu ConfigMap por esperantilo


if {![Object isobject IDE::ConfigmapBrowser]} {
    IDE::SystemConfigMap loadComponentFromAny IDEConfiguration
    IDE::ConfigmapBrowser newBrowser
} else {
    IDE::ConfigmapBrowser newBrowser
    IDE::ConfigmapControler reloadConfigmaps
}

set inst [IDE::ConfigurationMap new -name Esperantilo]
$inst makePersistent

set wcomps [list]
foreach c $comps {
    set cobj [IDE::Component getCompObjectForNameIfExist $c]
    lappend wcomps [IDE::ComponentConfWrapper::descriptor createInstanceFromDB IDE::ComponentConfWrapper [$cobj getIdValue]]
}
$inst setComponents $wcomps
${inst}::components updateList

$inst prescript "
package require xotcl::comm::httpd
encoding system utf-8"
set script {set ::progdir [pwd]
EsperantoConf initTk
EsperantoConf loadPreferences
EsperantoConf aliguLingvoTrace

Esperantilozentro set estasSDK 1
Esperantilozentro newBrowser
DBVortaro set forceMetakit 1
}

$inst postscript $script
$inst updateAttributes {postscript prescript}

$inst versionEdition

IDE::ConfigmapControler reloadConfigmaps

# kreu novan eldonon, per ke la medio estu preta por prilaboro

foreach c $comps {
    set cobj [IDE::Component getCompObjectForNameIfExist $c]
    $cobj createNewEdition
}

IDE::ConfigmapControler reloadConfigmaps

foreach c [IDE::ConfigurationMap info instances] {
    if {[$c set name] eq "Esperantilo"} {
        ${c}::components getList
	${c}::childconigmaps getList
        $c copyAndCreateNewEdition
	break
    }
}

IDE::ConfigmapControler reloadConfigmaps

foreach c [IDE::ConfigurationMap info instances] {
    if {[$c set name] eq "Esperantilo" && ![$c set isclosed]} {
       ${c}::components getList
       ${c}::childconigmaps getList
       $c setNewestEdtions
       ${c}::components updateList
       break
    }
}


IDE::System ignoreIDEComponents 1

$prot warning "Esperantilo estas sukcese importita. Uzu Configuration Browser preStart und start skriptoj por lancxi Esperantilon en XOTclIDE"
update idletasks

$prot warning "\n por sukcese programi Esperantilon. Vizitu kaj lernu www.tcl.tk www.xotcl.org www.xdobry.de/xotclIDE. Sukceson kun esperantilo"
update idletasks

eval $script
