param([string]$slug,[string[]]$names,[string]$out)
Add-Type -AssemblyName System.Drawing
$R="F:\project\design-library\apps\$slug"
if(-not $names){ $names = Get-ChildItem $R -Directory | Sort LastWriteTime | % Name }
$cw=640;$ch=380;$cols=3;$rows=[Math]::Ceiling($names.Count/$cols)
$bmp=New-Object Drawing.Bitmap ($cw*$cols),($ch*$rows);$g=[Drawing.Graphics]::FromImage($bmp);$g.Clear([Drawing.Color]::Gray)
$f=New-Object Drawing.Font 'Arial',14,([Drawing.FontStyle]::Bold)
for($i=0;$i -lt $names.Count;$i++){ $p="$R\$($names[$i])\shot-ai.jpg"; if(-not(Test-Path $p)){continue}; $im=[Drawing.Image]::FromFile($p); $x=($i%$cols)*$cw;$y=[Math]::Floor($i/$cols)*$ch; $g.DrawImage($im,$x+2,$y+22,$cw-4,$ch-24); $im.Dispose(); $g.DrawString($names[$i],$f,[Drawing.Brushes]::Yellow,$x+4,$y+2)}
$g.Dispose(); $bmp.Save($out,[Drawing.Imaging.ImageFormat]::Jpeg); $bmp.Dispose()