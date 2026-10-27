. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
# clean chatgpt main (dialog already closed)
Save-Shot 'codex' 'chatgpt-mode-main' @{
  app='Codex'; tier='first'; source='Codex desktop (process ChatGPT) — ChatGPT mode'
  tags=@('mode-chatgpt','sidebar','hero-composer','restrained')
  layout='ChatGPT mode main: icon rail + sidebar (置顶/项目/最近) + centered composer'
  nav='mode switcher -> ChatGPT'
  clicks=@('Button 切换模式，当前模式：Codex','MenuItem ChatGPT 创建、学习和探索','关闭欢迎对话框')
  notes='ChatGPT 模式首页（对照 Codex 模式）。已关欢迎弹窗。截完切回 Codex。'
  privacy='Shows ChatGPT chat titles; redact before sharing.'
}
$mode = Find-All $w '切换模式，当前模式：ChatGPT' 'Button' | Select -First 1
$how = Click-El $mode; Start-Sleep 1.5
"menu:"; Dump-Names $AE::RootElement @('MenuItem') | Select -First 10
$mi = Find-Root-All 'Codex 构建、调试和发布' 'MenuItem' | Select -First 1
if (-not $mi) { "Codex item missing"; exit 1 }
"switch: " + (Click-El $mi); Start-Sleep 3
$chk = Find-All $w '切换模式，当前模式：Codex' 'Button' | Select -First 1
if ($chk) { "CONFIRM back on Codex: $($chk.Current.Name)" } else {
  Dump-Names $w @('Button') | ? { $_ -match '切换模式' }
  "FAIL still not Codex"
}
Remove-Item -Recurse -Force F:\project\design-library\apps\codex\_chatgpt-state -ErrorAction SilentlyContinue