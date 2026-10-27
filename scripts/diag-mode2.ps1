. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
$close = Find-All $w '关闭对话框' 'Button' | Select -First 1
if ($close) { "close dialog: " + (Click-El $close); Start-Sleep 2 }
Press-Esc; Start-Sleep 1
Dump-Names $w @('Button','MenuItem') | Select -First 60
$all = $w.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
foreach ($e in $all) {
  try {
    $n = $e.Current.Name
    if ($n -and ($n -match '切换模式|当前模式|Codex|ChatGPT')) {
      $r = $e.Current.BoundingRectangle
      "{0}`t{1}`t{2},{3}" -f ($e.Current.ControlType.ProgrammaticName -replace 'ControlType.',''), $n, [int]$r.X, [int]$r.Y
    }
  } catch {}
}