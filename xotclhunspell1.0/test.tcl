package require XOTcl
package require xotcl::hunspell
namespace import xotcl::*

set checker [Hunspell new]
set dic {/home/artur/programs/hunspell-1.1.4/dictionaries}
$checker open [file join $dic eo-EO.aff] [file join $dic eo-EO.dic]
puts "dic encoding [$checker getDicEncoding]"
$checker encoding iso8859-3
#puts "encoding [$checker encoding]"
puts "faras [$checker spell faras]"
puts "farras [$checker spell farras]"
puts [join [$checker suggest farras] ,]
puts [join [$checker suggest xyeeerew] ,]

puts "artur [$checker spell artur]"
$checker putWord "artur"
puts "artur after putWord [$checker spell artur]"

puts "pipolo [$checker spell pipolo]"
$checker putWordPattern pipolo homo
puts "pipolo after putWordPattern [$checker spell pipolo]"
puts "pipoloj after putWordPattern [$checker spell pipoloj]"
puts "pipolojn after putWordPattern [$checker spell pipolojn]"

puts "stem faris [$checker stem faris]"
puts "morph faris '[$checker morph faris]'"
puts "morph as '[$checker morph ino]'"
puts "morph fari '[$checker morph fari]'"

$checker close
$checker destroy
