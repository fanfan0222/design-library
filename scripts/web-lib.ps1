# web-lib.ps1 - helpers for capturing web apps in Chrome (reuses uia-lib.ps1)
. F:\project\design-library\scripts\uia-lib.ps1
$script:Chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
function Get-ChromeWin {
  $p = Get-Process chrome -ErrorAction SilentlyContinue | ? { $_.MainWindowHandle -ne 0 } | Select -First 1
  if (-not $p) { return $null }
  return $AE::FromHandle($p.MainWindowHandle)
}
function Focus-Chrome { return (Focus-App 'chrome') }
function Send-Keys([string]$k) { [System.Windows.Forms.SendKeys]::SendWait($k); Start-Sleep -Milliseconds 200 }
function Go-Url([string]$url, [int]$wait = 6) {
  $w = Focus-Chrome
  Send-Keys '^l'; Start-Sleep -Milliseconds 300
  [System.Windows.Forms.Clipboard]::SetText($url); Send-Keys '^v'; Send-Keys '{ENTER}'
  Start-Sleep $wait
  return (Focus-Chrome)
}
function Save-WebShot([string]$slug, [string]$screen, [hashtable]$meta) {
  $r = Save-Shot $slug $screen $meta
  $mp = Join-Path $script:Root "apps\$slug\$screen\meta.json"
  $m = Get-Content -Raw -Encoding UTF8 $mp | ConvertFrom-Json
  $m.platform = 'web'
  $m | Add-Member -NotePropertyName url -NotePropertyValue $meta.url -Force
  $m | Add-Member -NotePropertyName browser -NotePropertyValue 'Google Chrome (default profile), maximized' -Force
  [IO.File]::WriteAllText($mp, ($m | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  return $r
}
Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public static class W32b { [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int ht,bool r); }
"@ -ErrorAction SilentlyContinue
function Chrome-ToPrimary {
  $p = Get-Process chrome | ? { $_.MainWindowHandle -ne 0 } | Select -First 1
  $h = $p.MainWindowHandle
  [void][W32]::ShowWindow($h, 9); Start-Sleep -Milliseconds 400
  [void][W32b]::MoveWindow($h, 100, 100, 2000, 1400, $true); Start-Sleep -Milliseconds 400
  [void][W32]::ShowWindow($h, 3); Start-Sleep -Milliseconds 600
}

# fast override: native PropertyCondition search (web pages have huge UIA trees)
function Find-All($el, [string]$name, [string]$type) {
  $PC = [System.Windows.Automation.PropertyCondition]
  $c = New-Object $PC ([System.Windows.Automation.AutomationElement]::NameProperty), $name
  if ($type) {
    $ct = [System.Windows.Automation.ControlType]::$type
    $c2 = New-Object $PC ([System.Windows.Automation.AutomationElement]::ControlTypeProperty), $ct
    $c = New-Object System.Windows.Automation.AndCondition $c, $c2
  }
  $r = $el.FindAll($TS::Descendants, $c); return @($r)
}
function Find-Type($el, [string]$type) {
  $c = New-Object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ControlTypeProperty), ([System.Windows.Automation.ControlType]::$type)
  return @($el.FindAll($TS::Descendants, $c))
}
function CurUrl { $w=Focus-Chrome; $e = Find-All $w '地址和搜索栏' 'Edit' | Select -First 1; if($e){ try { $e.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch {''} } }
