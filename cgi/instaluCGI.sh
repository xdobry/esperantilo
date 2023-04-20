#!/bin/bash

CelaDos=/var/www/cgi-bin
WWWDos=/var/www/html

echo "Cgi-dosiero $CelaDos"

if test ! -d $CelaDos; then
echo "Dosiero $CelaDos ne ekzistas"
exit
fi

if test ! -d $WWWDos; then
echo "Dosiero $WWWDos ne ekzistas"
exit
fi

echo "Chu instali Esperantilo kiel CGI j/n"
read INPUT
if test $INPUT != "j" ; then
exit 
fi

espdosieroj="radikoj.xotcl pkgIndex.tcl Esperantilo.tcl EspAnalizoj.xotcl EspBazaLingvo.xotcl EspHTTPServilo.xotcl EspSintaksaAnalizo.xotcl gramreguloj.txt"

cp kontrolilo.html $WWWDos
chown apache $WWWDos/kontrolilo.html

cp respondo.tmp $CelaDos
cp gramatika-kontrolado $CelaDos
cd ..
cp $espdosieroj $CelaDos

cd $CelaDos
chown apache $espdosieroj respondo.tmp gramatika-kontrolado
chmod uga-x $espdosieroj gramatika-kontrolado respondo.tmp
chmod u+x gramatika-kontrolado

