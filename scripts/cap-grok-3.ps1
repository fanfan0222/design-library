. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Grok Bot'; tier='first'; source='Grok Bot desktop'; privacy='Settings may show account/usage/machine names; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'Grok Bot'
$sw = Find-All $w 'Grok Bot 设置' 'Window' | Select -First 1
if (-not $sw) { "settings window not open"; exit 1 }
$map = [ordered]@{ '电脑'='settings-computer'; '用量与账单'='settings-usage'; '更新'='settings-updates'; '通用'='settings-general' }
foreach ($k in $map.Keys) {
  $b = Find-All $sw $k 'Button' | Select -First 1
  if (-not $b) { "MISSING nav $k"; continue }
  $how = Click-El $b; Start-Sleep 1.8
  "--- $k"; Dump-Names $sw @('Text','Button') | Select -First 25
  if ($k -ne '通用') { Save-Shot 'grok-bot' $map[$k] (M @{ tags=@('settings-dialog','modal','section-nav','restrained'); layout="settings modal, section $k"; nav='settings left nav 通用/电脑/用量与账单/更新'; clicks=@('Button 打开账户菜单 (Expand)','MenuItem 设置 (Invoke)',"Button $k ($how)"); notes="设置-$k 分区，仅查看" }) }
}
$c = Find-All $sw '关闭' 'Button' | Select -First 1; [void](Click-El $c); Start-Sleep 1
Press-Esc