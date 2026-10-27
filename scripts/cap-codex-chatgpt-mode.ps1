. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
Press-Esc; Start-Sleep 1
# leave settings if still there
$h = Find-All $w '首页' 'Button' | ? { $_.Current.BoundingRectangle.X -lt 100 } | Select -First 1
if ($h) { [void](Click-El $h); Start-Sleep 2 }
$mode = Find-All $w '切换模式，当前模式：Codex' 'Button' | Select -First 1
if (-not $mode) {
  $mode = Find-All $w '切换模式，当前模式：ChatGPT' 'Button' | Select -First 1
  if ($mode) { "already ChatGPT mode"; }
  else { "mode button missing"; Dump-Names $w @('Button') | Select -First 30; exit 1 }
}
if ($mode.Current.Name -like '*Codex*') {
  $how = Click-El $mode; Start-Sleep 1.2
  $mi = Find-Root-All 'ChatGPT 创建、学习和探索' 'MenuItem' | Select -First 1
  if (-not $mi) { "ChatGPT menu item missing"; Press-Esc; exit 1 }
  $how2 = Click-El $mi; Start-Sleep 3
  "switched to ChatGPT via $how / $how2"
} else { "already on ChatGPT" }
Save-Shot 'codex' 'chatgpt-mode-main' @{
  app='Codex'; tier='first'; source='Codex desktop (process ChatGPT) — ChatGPT mode'
  tags=@('mode-chatgpt','sidebar','hero-composer','restrained')
  layout='ChatGPT mode main: icon rail + sidebar + centered hero/composer (contrast with Codex mode)'
  nav='mode switcher -> ChatGPT'
  clicks=@('Button 切换模式，当前模式：Codex','MenuItem ChatGPT 创建、学习和探索')
  notes='ChatGPT 模式首页，仅作对照。截完立即切回 Codex。'
  privacy='May show chat titles / account chrome; redact before sharing.'
}
# switch back to Codex
$mode2 = Find-All $w '切换模式，当前模式：ChatGPT' 'Button' | Select -First 1
if (-not $mode2) { $mode2 = Find-All $w '切换模式' 'Button' | Select -First 1 }
if ($mode2) {
  [void](Click-El $mode2); Start-Sleep 1.2
  $mi2 = Find-Root-All 'Codex 构建、调试和发布' 'MenuItem' | Select -First 1
  if ($mi2) { [void](Click-El $mi2); Start-Sleep 2.5; "switched back to Codex" } else { "WARN: Codex menu item missing — leave for user" }
} else { "WARN: could not find mode button to switch back" }
$chk = Find-All $w '切换模式，当前模式：Codex' 'Button' | Select -First 1
if ($chk) { "CONFIRM back on Codex" } else { Dump-Names $w @('Button') | ? { $_ -match '切换模式' } }