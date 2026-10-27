param([string]$slug)
Add-Type -AssemblyName System.Drawing
$dirs = Get-ChildItem "F:\project\design-library\apps\$slug" -Directory | Sort Name
$cols=4; $tw=640; $th=360; $rows=[math]::Ceiling($dirs.Count/$cols)
$bmp = New-Object System.Drawing.Bitmap ($cols*$tw), ($rows*($th+30))
$g=[System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::White)
$f = New-Object System.Drawing.Font 'Arial',14
$i=0; foreach($d in $dirs){ $img=[System.Drawing.Image]::FromFile("$($d.FullName)\shot-ai.jpg"); $x=($i%$cols)*$tw; $y=[math]::Floor($i/$cols)*($th+30)
 $g.DrawImage($img,$x,$y+30,$tw-6,$th-6); $g.DrawString($d.Name,$f,[System.Drawing.Brushes]::Black,$x+4,$y+4); $img.Dispose(); $i++ }
$bmp.Save("C:\Users\fanfan\dl-check\sheet-$slug.jpg",[System.Drawing.Imaging.ImageFormat]::Jpeg); "ok $($dirs.Count)"