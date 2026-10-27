# uia-lib.ps1 - Design library capture helpers (DPI-aware UIA + 4K capture)
Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public static class W32 {
  [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr v);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, IntPtr e);
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte sc, uint f, IntPtr e);
}
"@
[void][W32]::SetProcessDpiAwarenessContext([IntPtr]-4)
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Windows.Forms, System.Drawing
$script:Root = 'F:\project\design-library'
$AE = [System.Windows.Automation.AutomationElement]
$TS = [System.Windows.Automation.TreeScope]

function Get-AppWindow([string]$proc) {
  $p = Get-Process -Name $proc -ErrorAction Stop | ? { $_.MainWindowHandle -ne 0 } | Select -First 1
  return $p.MainWindowHandle
}
function Focus-App([string]$proc) {
  $h = Get-AppWindow $proc
  [void][W32]::ShowWindow($h, 3); Start-Sleep -Milliseconds 300
  # alt tap to allow foreground
  [W32]::keybd_event(0x12,0,0,[IntPtr]::Zero); [W32]::keybd_event(0x12,0,2,[IntPtr]::Zero)
  [void][W32]::SetForegroundWindow($h); Start-Sleep -Milliseconds 700
  return $AE::FromHandle($h)
}
function Find-All($el, [string]$name, [string]$type) {
  $all = $el.FindAll($TS::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
  $res = @()
  foreach ($e in $all) {
    try { $n = $e.Current.Name; $t = $e.Current.ControlType.ProgrammaticName } catch { continue }
    if ($n -eq $name -and (-not $type -or $t -eq "ControlType.$type")) { $res += $e }
  }
  return $res
}
function Find-Root-All([string]$name, [string]$type) {
  # search all top-level windows too (menus/popups/dialogs)
  return Find-All $AE::RootElement $name $type
}
function Click-El($el) {
  $p = $null
  if ($el.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$p)) { $p.Invoke(); return 'Invoke' }
  if ($el.TryGetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern, [ref]$p)) { $p.Select(); return 'Select' }
  if ($el.TryGetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern, [ref]$p)) { $p.Expand(); return 'Expand' }
  if ($el.TryGetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern, [ref]$p)) { $p.Toggle(); return 'Toggle' }
  return (Mouse-Click $el)
}
function Mouse-Click($el) {
  $r = $el.Current.BoundingRectangle
  $x = [int]($r.X + $r.Width/2); $y = [int]($r.Y + $r.Height/2)
  [void][W32]::SetCursorPos($x,$y); Start-Sleep -Milliseconds 120
  [W32]::mouse_event(2,0,0,0,[IntPtr]::Zero); [W32]::mouse_event(4,0,0,0,[IntPtr]::Zero)
  return "MouseClick($x,$y)"
}
function Press-Esc { [W32]::keybd_event(0x1B,0,0,[IntPtr]::Zero); [W32]::keybd_event(0x1B,0,2,[IntPtr]::Zero); Start-Sleep -Milliseconds 400 }
function Mouse-Away { $b=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; [void][W32]::SetCursorPos([int]($b.Width/2), [int]($b.Height*0.45)) }
function Dump-Names($el, [string[]]$types) {
  $all = $el.FindAll($TS::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
  foreach ($e in $all) { try {
    $t = $e.Current.ControlType.ProgrammaticName -replace 'ControlType\.',''
    if ($types -and ($types -notcontains $t)) { continue }
    $n = $e.Current.Name; if (-not $n) { continue }
    $r = $e.Current.BoundingRectangle
    "{0}`t{1}`t{2},{3},{4},{5}" -f $t, ($n -replace "`r|`n",' ').Substring(0,[Math]::Min(80,$n.Length)), [int]$r.X,[int]$r.Y,[int]$r.Width,[int]$r.Height
  } catch {} }
}
function Save-Shot([string]$slug, [string]$screen, [hashtable]$meta, [switch]$NoMouseAway) {
  if (-not $NoMouseAway) { Mouse-Away }
  Start-Sleep -Milliseconds 900
  $dir = Join-Path $script:Root "apps\$slug\$screen"; New-Item -ItemType Directory -Force $dir | Out-Null
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size); $g.Dispose()
  $full = Join-Path $dir 'shot.png'; $bmp.Save($full, [System.Drawing.Imaging.ImageFormat]::Png)
  $w = 1920; $h = [int]($b.Height * 1920 / $b.Width)
  $sm = New-Object System.Drawing.Bitmap $w, $h
  $g2 = [System.Drawing.Graphics]::FromImage($sm); $g2.InterpolationMode = 'HighQualityBicubic'; $g2.DrawImage($bmp, 0,0,$w,$h); $g2.Dispose()
  $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ? { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 82L
  $ai = Join-Path $dir 'shot-ai.jpg'; $sm.Save($ai, $enc, $ep); $sm.Dispose(); $bmp.Dispose()
  $m = [ordered]@{ app=$meta.app; screen=$screen; tier=$meta.tier; style_tags=$meta.tags; layout=$meta.layout; nav=$meta.nav;
    platform='Windows desktop'; source=$meta.source; clicks=$meta.clicks; notes=$meta.notes; privacy=$meta.privacy;
    captured_at=(Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'); capture_mode='fullscreen-physical';
    full_px="$($b.Width)x$($b.Height)"; ai_px="${w}x$h"; shot_full='shot.png'; shot_ai='shot-ai.jpg';
    bytes=@{ full=(Get-Item $full).Length; ai=(Get-Item $ai).Length } }
  [IO.File]::WriteAllText((Join-Path $dir 'meta.json'), ($m | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  "SAVED $slug/$screen $($b.Width)x$($b.Height) ai=$((Get-Item $ai).Length)"
}