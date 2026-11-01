# opencli-lib.ps1 - capture web apps in the USER's own Chrome via OpenCLI browser bridge
$env:NO_UPDATE_NOTIFIER = '1'
$script:Root = 'F:\project\design-library'
if (-not $script:S) { $script:S = 'cg' }
Add-Type -AssemblyName System.Drawing
function OC { & opencli browser --session $script:S @args 2>$null }
function OCw([double]$s = 2) { Start-Sleep -Milliseconds ([int]($s*1000)) }
function OCurl { (OC eval 'location.href' | Out-String).Trim().Trim('"') }
function Snap {
  param([string]$slug, [string]$app, [string]$screen, [string]$title, [string[]]$tags, [string]$layout, [string]$nav, [string[]]$clicks, [string]$notes, [string]$privacy = 'Logged-in UI; may show account name / chat titles.', [int]$W = 1920, [int]$H = 1080, [switch]$Full)
  $dir = Join-Path $script:Root "apps\$slug\$screen"
  if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
  New-Item -ItemType Directory -Force $dir | Out-Null
  $png = Join-Path $dir 'shot.png'; $jpg = Join-Path $dir 'shot-ai.jpg'
  if ($Full) { OC screenshot $png --full-page | Out-Null } else { OC screenshot $png --width $W --height $H | Out-Null }
  if (-not (Test-Path $png)) { Write-Host "FAIL $screen"; return }
  $img = [Drawing.Image]::FromFile($png); $w = $img.Width; $h = $img.Height
  $tw = [Math]::Min(1920, $w); $th = [int]($h * $tw / $w)
  $bmp = New-Object Drawing.Bitmap $tw, $th; $g = [Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($img, 0, 0, $tw, $th); $g.Dispose(); $img.Dispose()
  $enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ? { $_.MimeType -eq 'image/jpeg' } | Select -First 1
  $ep = New-Object Drawing.Imaging.EncoderParameters 1; $ep.Param[0] = [Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality, [long]82)
  $bmp.Save($jpg, $enc, $ep); $bmp.Dispose()
  $meta = [ordered]@{ app = $app; screen = $screen; title = $title; tier = 'first'; style_tags = $tags; layout = $layout; nav = $nav; platform = 'web';
    source = 'User Chrome on fanfan (logged in) via OpenCLI browser bridge'; tool = 'opencli'; clicks = $clicks; notes = $notes; privacy = $privacy;
    captured_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'); capture_mode = $(if ($Full) {'opencli-fullpage'} else {"opencli-viewport-${W}x$H"});
    full_px = "${w}x$h"; ai_px = "${tw}x$th"; shot_full = 'shot.png'; shot_ai = 'shot-ai.jpg';
    bytes = @{ full = (Get-Item $png).Length; ai = (Get-Item $jpg).Length }; url = (OCurl); logged_in = $true; machine = 'fanfan' }
  [IO.File]::WriteAllText((Join-Path $dir 'meta.json'), ($meta | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))
  Write-Host "OK $slug/$screen ${w}x$h"
}
