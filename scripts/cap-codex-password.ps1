. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
function Open-Settings {
  $b = Find-All $w '打开个人资料菜单' 'Button' | Select -First 1
  [void](Click-El $b); Start-Sleep 1.2
  $mi = Find-Root-All '设置 Ctrl+,' 'MenuItem' | Select -First 1
  [void](Click-El $mi); Start-Sleep 2.5
}
function NavBtn($k) {
  Find-All $w $k 'Button' | ? { $r=$_.Current.BoundingRectangle; $r.X -gt 100 -and $r.X -lt 200 -and $r.Width -gt 400 } | Select -First 1
}
Open-Settings
$b = NavBtn '密码'
if (-not $b) {
  # scroll settings list
  $all = Find-All $w '密码' 'Button'
  $b = $all | Select -First 1
}
if (-not $b) { "MISSING 密码"; Dump-Names $w @('Button') | ? { $_.Current -match '密|密' -or $_ -match '密' } | Select -First 20; exit 1 }
try { $b.GetCurrentPattern([System.Windows.Automation.ScrollItemPattern]::Pattern).ScrollIntoView(); Start-Sleep -Milliseconds 400 } catch {}
$how = Click-El $b; Start-Sleep 2.5
"--- password page texts (sanitized: no secret values logged)"
Dump-Names $w @('Text','Button','Edit') | ? { $_ -notmatch 'password|密码值|••••|•{3,}' } | Select -First 40
Save-Shot 'codex' 'settings-password' @{
  app='Codex'; tier='first'; source='Codex desktop (process ChatGPT)'
  tags=@('settings-page','section-nav','credentials-ui','restrained')
  layout='full-page settings: left grouped section list + right form (密码)'
  nav='settings nav [集成] -> 密码'
  clicks=@('Button 打开个人资料菜单','MenuItem 设置 Ctrl+, (Invoke)',"Button 密码 ($how)")
  notes='Codex 设置 - 密码分区 UI 布局（仅查看截图）。meta 不记录任何密钥/口令内容。'
  privacy='Password/credential UI; may show account identifiers. Redact before sharing. No secret values copied into meta.'
}
Press-Esc