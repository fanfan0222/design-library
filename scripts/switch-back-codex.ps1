. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
"--- mode-related buttons"
Dump-Names $w @('Button','MenuItem') | ? { $_ -match '切换|Codex|ChatGPT|模式' } | Select -First 30
$cands = @()
foreach ($n in @('切换模式，当前模式：ChatGPT','切换模式，当前模式：Codex','ChatGPT','Codex')) {
  $cands += ,(Find-All $w $n 'Button')
}
"trying expand any switcher"
$all = $w.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
foreach ($e in $all) {
  try {
    $n = $e.Current.Name
    if (-not $n) { continue }
    if ($n -match '切换模式|当前模式') {
      "FOUND: $n / $($e.Current.ControlType.ProgrammaticName) / $($e.Current.BoundingRectangle)"
      $how = Click-El $e; Start-Sleep 1.5
      Dump-Names $AE::RootElement @('MenuItem') | Select -First 12
      $mi = Find-Root-All 'Codex 构建、调试和发布' 'MenuItem' | Select -First 1
      if ($mi) { "back: " + (Click-El $mi); Start-Sleep 2.5 }
      break
    }
  } catch {}
}
Start-Sleep 1
Dump-Names $w @('Button') | ? { $_ -match '切换|Codex|ChatGPT' } | Select -First 10