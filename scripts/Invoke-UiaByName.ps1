<#
.SYNOPSIS
  Find a top-level window by process name and/or title, find a control by its UIA Name,
  then Expand / Invoke / Select / Toggle / Click it, optionally waiting for something to appear.

.DESCRIPTION
  Uses Windows' built-in UI Automation (System.Windows.Automation, UIAutomationClient).
  Searches ALL top-level windows of the target process (popup menus and dialogs in
  Electron/Chromium apps are often separate top-level windows).

  Action 'Auto' order: ExpandCollapse.Expand -> Invoke -> SelectionItem.Select -> Toggle -> mouse click.
  Mouse fallback clicks the centre of BoundingRectangle (process is set PerMonitorV2 DPI-aware,
  so coordinates are physical pixels).

.PARAMETER ProcessName  e.g. 'Grok Bot' or 'ChatGPT' (without .exe). Optional if -WindowTitle given.
.PARAMETER WindowTitle  Wildcard on window title, e.g. 'Grok Bot*' or 'ChatGPT'.
.PARAMETER Name         Control Name to find (exact, unless -Match).
.PARAMETER Match        Treat -Name as a regex instead of exact match.
.PARAMETER ControlType  Optional filter: Button, MenuItem, TabItem, ListItem, Hyperlink, ...
.PARAMETER Index        Pick the Nth match (0-based) when several controls share the Name.
.PARAMETER Action       Auto | Expand | Collapse | Invoke | Select | Toggle | Click | Focus | None (just find & report).
.PARAMETER WaitForName  After acting, wait until a control with this Name appears (any window of the process).
.PARAMETER WaitForWindowTitle  After acting, wait until a top-level window with this title (wildcard) appears.
.PARAMETER TimeoutSec   Timeout for finding the target and for the wait (default 10).
.PARAMETER Foreground   Bring the window to the foreground first.
.PARAMETER List         List named controls in the window(s) (for discovery) and exit.

.EXAMPLE
  # Proven path on Grok Bot: account menu -> Settings
  .\Invoke-UiaByName.ps1 -ProcessName 'Grok Bot' -Name '打开账户菜单' -Action Expand -WaitForName '设置' -Foreground
  .\Invoke-UiaByName.ps1 -ProcessName 'Grok Bot' -Name '设置' -ControlType MenuItem -Action Invoke -WaitForWindowTitle '*设置*'

.EXAMPLE
  .\Invoke-UiaByName.ps1 -ProcessName ChatGPT -List | Out-GridView
#>
[CmdletBinding()]
param(
  [string]$ProcessName,
  [string]$WindowTitle,
  [string]$Name,
  [switch]$Match,
  [string]$ControlType,
  [int]$Index = 0,
  [ValidateSet('Auto', 'Expand', 'Collapse', 'Invoke', 'Select', 'Toggle', 'Click', 'Focus', 'None')]
  [string]$Action = 'Auto',
  [string]$WaitForName,
  [string]$WaitForWindowTitle,
  [int]$TimeoutSec = 10,
  [switch]$Foreground,
  [switch]$List
)

$ErrorActionPreference = 'Stop'
if (-not $ProcessName -and -not $WindowTitle) { throw 'Give -ProcessName and/or -WindowTitle.' }
if (-not $List -and -not $Name) { throw 'Give -Name (or use -List).' }

if (-not ('DlNative.Input' -as [type])) {
  Add-Type -Namespace DlNative -Name Input -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr value);
[DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
[DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int cmd);
[DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
'@
}
try { [void][DlNative.Input]::SetProcessDpiAwarenessContext([IntPtr](-4)) } catch {}

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$AE = [System.Windows.Automation.AutomationElement]
$TS = [System.Windows.Automation.TreeScope]

function Get-TargetWindows {
  $pids = @()
  if ($ProcessName) {
    $pids = @(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
    if (-not $pids) { return @() }
  }
  $all = $AE::RootElement.FindAll($TS::Children, [System.Windows.Automation.Condition]::TrueCondition)
  $res = @()
  foreach ($w in $all) {
    try {
      $c = $w.Current
      if ($pids -and ($pids -notcontains $c.ProcessId)) { continue }
      if ($WindowTitle -and ($c.Name -notlike $WindowTitle)) { continue }
      $res += $w
    } catch {}
  }
  return $res
}

function Find-Named([string]$targetName, [string]$ctype, [switch]$regex) {
  $hits = @()
  foreach ($w in (Get-TargetWindows)) {
    try {
      $cond = [System.Windows.Automation.Condition]::TrueCondition
      if (-not $regex) {
        $cond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, $targetName)
      }
      if ($ctype) {
        $ct = [System.Windows.Automation.ControlType]::$ctype
        if (-not $ct) { throw "Unknown ControlType '$ctype'" }
        $ctCond = New-Object System.Windows.Automation.PropertyCondition($AE::ControlTypeProperty, $ct)
        $cond = New-Object System.Windows.Automation.AndCondition($cond, $ctCond)
      }
      foreach ($e in $w.FindAll($TS::Subtree, $cond)) {
        if ($regex -and ($e.Current.Name -notmatch $targetName)) { continue }
        $hits += $e
      }
    } catch [System.Windows.Automation.ElementNotAvailableException] {}
  }
  return $hits
}

function Describe($e) {
  $c = $e.Current
  [pscustomobject]@{
    Name         = $c.Name
    ControlType  = $c.ControlType.ProgrammaticName -replace '^ControlType\.', ''
    AutomationId = $c.AutomationId
    ClassName    = $c.ClassName
    Rect         = $c.BoundingRectangle.ToString()
    Patterns     = (($e.GetSupportedPatterns() | ForEach-Object { $_.ProgrammaticName -replace 'PatternIdentifiers\.Pattern$', '' }) -join ',')
  }
}

function Try-Pattern($e, $patternType) {
  $p = $null
  if ($e.TryGetCurrentPattern($patternType::Pattern, [ref]$p)) { return $p }
  return $null
}

function Click-Mouse($e) {
  $r = $e.Current.BoundingRectangle
  if ($r.IsEmpty -or $r.Width -le 0) { throw 'Element has no bounding rectangle; cannot mouse-click.' }
  $cx = [int]($r.X + $r.Width / 2); $cy = [int]($r.Y + $r.Height / 2)
  [void][DlNative.Input]::SetCursorPos($cx, $cy)
  Start-Sleep -Milliseconds 60
  [DlNative.Input]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)  # LEFTDOWN
  [DlNative.Input]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)  # LEFTUP
  return "Mouse($cx,$cy)"
}

# --- discovery mode ---
$wins = Get-TargetWindows
if (-not $wins) { throw "No window found (ProcessName='$ProcessName', WindowTitle='$WindowTitle')." }

if ($Foreground) {
  $h = [IntPtr]$wins[0].Current.NativeWindowHandle
  if ([DlNative.Input]::IsIconic($h)) { [void][DlNative.Input]::ShowWindow($h, 9) }  # SW_RESTORE
  [void][DlNative.Input]::SetForegroundWindow($h)
  Start-Sleep -Milliseconds 250
}

if ($List) {
  foreach ($w in $wins) {
    foreach ($e in $w.FindAll($TS::Subtree, [System.Windows.Automation.Condition]::TrueCondition)) {
      try { if ($e.Current.Name) { $d = Describe $e; $d | Add-Member Window $w.Current.Name; $d } } catch {}
    }
  }
  return
}

# --- find target ---
$deadline = (Get-Date).AddSeconds($TimeoutSec)
$hits = @()
do {
  $hits = @(Find-Named $Name $ControlType -regex:$Match)
  if ($hits.Count -gt $Index) { break }
  Start-Sleep -Milliseconds 250
} while ((Get-Date) -lt $deadline)
if ($hits.Count -le $Index) { throw "Control Name='$Name' ControlType='$ControlType' not found (matches: $($hits.Count))." }
$el = $hits[$Index]
$info = Describe $el

# --- act ---
$used = 'None'
switch ($Action) {
  'None'     { }
  'Focus'    { $el.SetFocus(); $used = 'SetFocus' }
  'Click'    { $used = Click-Mouse $el }
  'Expand'   { $p = Try-Pattern $el ([System.Windows.Automation.ExpandCollapsePattern]); if (-not $p) { throw 'ExpandCollapsePattern not supported.' }; $p.Expand(); $used = 'Expand' }
  'Collapse' { $p = Try-Pattern $el ([System.Windows.Automation.ExpandCollapsePattern]); if (-not $p) { throw 'ExpandCollapsePattern not supported.' }; $p.Collapse(); $used = 'Collapse' }
  'Invoke'   { $p = Try-Pattern $el ([System.Windows.Automation.InvokePattern]); if (-not $p) { throw 'InvokePattern not supported.' }; $p.Invoke(); $used = 'Invoke' }
  'Select'   { $p = Try-Pattern $el ([System.Windows.Automation.SelectionItemPattern]); if (-not $p) { throw 'SelectionItemPattern not supported.' }; $p.Select(); $used = 'Select' }
  'Toggle'   { $p = Try-Pattern $el ([System.Windows.Automation.TogglePattern]); if (-not $p) { throw 'TogglePattern not supported.' }; $p.Toggle(); $used = 'Toggle' }
  'Auto' {
    $done = $false
    foreach ($pair in @(
        @([System.Windows.Automation.ExpandCollapsePattern], 'Expand'),
        @([System.Windows.Automation.InvokePattern], 'Invoke'),
        @([System.Windows.Automation.SelectionItemPattern], 'Select'),
        @([System.Windows.Automation.TogglePattern], 'Toggle'))) {
      $p = Try-Pattern $el $pair[0]
      if ($p) {
        try {
          switch ($pair[1]) {
            'Expand' { $p.Expand() }
            'Invoke' { $p.Invoke() }
            'Select' { $p.Select() }
            'Toggle' { $p.Toggle() }
          }
        } catch { continue }
        $used = $pair[1]; $done = $true; break
      }
    }
    if (-not $done) { $used = Click-Mouse $el }
  }
}

# --- optional wait ---
$waitResult = $null
if ($WaitForName -or $WaitForWindowTitle) {
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  $ok = $false
  do {
    Start-Sleep -Milliseconds 250
    if ($WaitForName -and (@(Find-Named $WaitForName $null).Count -gt 0)) { $ok = $true }
    if ($WaitForWindowTitle) {
      $tw = $AE::RootElement.FindAll($TS::Children, [System.Windows.Automation.Condition]::TrueCondition) |
        Where-Object { try { $_.Current.Name -like $WaitForWindowTitle } catch { $false } }
      if ($tw) { $ok = $true }
    }
  } while (-not $ok -and (Get-Date) -lt $deadline)
  $waitResult = $(if ($ok) { 'appeared' } else { 'timeout' })
  if (-not $ok) { Write-Warning "Wait timed out after ${TimeoutSec}s." }
}

$info | Add-Member Action $used
$info | Add-Member Matches $hits.Count
$info | Add-Member Wait $waitResult
$info
