Tiu dokumento priskribas kiel uzi la gramatikon korektilon de Esperantilo
en TTT-servilo.
Ekzistas nun du manieroj fari tion:

1) Lanĉi Esperantilon kiel TTT-Servilo. Esperantilo funkcias poste kiel memstara TTT-Servilo, kiu aŭdas demandojn sur specifa pordo.
   tclsh Esperantilo.tcl -httpServilo 8080
   ./tclkit-linux-x86_8412enc Esperantilo.tcl -httpServilo 8080
Tiu lanĉas la servilon sur porto 8080

2) Uzi Esperantilon per CGI-interfaco.

Mi nun priskibas, kiul instali kaj uzi Esperantilion en CGI-Modu kun TTT-Servilo Apache
sur Linukso. Simile oni instalu la programon ankaŭ por aliaj TTT-Serviloj aŭ operaciumaj sistemoj

=Kondicoj=

Vi necesas Tcl kun XOTcl aldona biblioteko.
Tcl estas ofte sur linukso jam instalita.
Por XOTcl vi povas instali de fontoj de http://www.xotcl.org

Vi Tcl interpretilo estas preta por Esperantilo, se vi povas senerare plenumi tiun komandon

 [artur@localhost cgi]$ /opt/tcl8412/bin/tclsh8.4
 % package require XOTcl
 1.5.2
 %

En tiu kazo, la konvena Tcl interpretilo estas en dosierujo /opt/tcl8412/bin/tclsh8.4

=Instalado

Vi devas kopii kelkajn dosierojn en la cgi-dosierujon de via servio.
Vi devas ankaŭ krei aŭ kopii la HTML-formularon por la CGI.
La ekzempla html-paĝo estas en tiu dosiero kaj nomiĝas kontrolilo.html
Grave estas, ke la CGI-programo, atendas la tekston por korektado en kampo "teksto".

Ekzistas ekzempla programo por instalado de Esperantilo kiel CGI en
tiu dosiero: "instaluCGI.sh"
Por lanĉu tiun programon vi devas havi la administrajn rajtojn ("root") sur via komputilo.
Mi testis la programon kun Linukso "Fedora Core 5".

Vi devas scii, kie estas via cgi-dosierujo.
Tio estas definita en doesioer httpd.conf de via Apache-Servilo.
Sur mia komputilo ĝi kuŝas en: /etc/httpd/conf/

La Cgi-dosiero estas /var/www/cgi-bin

La ĉefa programo por lanĉo estas "gramatika-kontrolado".
La unua linio de tiu dosiero (estas teksta dosiero) definas, kie estas la Tcl-Interpretilo.

En mia kazo la linio estas
#!/opt/tcl8412/bin/tclsh8.4

Se vi instalas la dosierojn mane. Vi devas meti la proprietulon de tiuj dosierujoj sur "apache", aŭ uzanto, kiujn kuras vian TTT-Servilon.
La uniksa komando estas:
chown apache *.xotcl *.tcl gramatika-kontrolado

La dosierujo "gramatika-kontrolado" necesas ankaŭ la "x" (Execute) markilon.

=Sekureco=

Kontrolu la proprietulon kaj rajton de ĉiu doserio.
Legu plu en dokumentaro de via TTT-Servilo

=Proplemoj=

Rigardu la eraran dosieron de via TTT-Servilo
/var/log/httpd/errors_log
(Aŭ alia dosiero depende de via TTT-Servilo)

=Adaptado=

Vi povas adapti la ŝablonon de respondo.
Tio estas la dosiero "respondo.tmp".
Atentu, ke variabl $respondo estas tauŝita per programo kun respondo.
Por pluaj adaptadoj vidu la modulon EspHTTPServilo.xotcl objekto CgiWorker
kaj klason GramatikHTMLAnalizilo en la sama modulo.

=Uzado=

Lanĉu vian ttt-montrilon sur
http://127.0.0.1/kontrolilo.html


