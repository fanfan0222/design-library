param([string]$proc,[string]$types='')
. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App $proc
$t = if ($types) { $types -split ',' } else { $null }
Dump-Names $w $t