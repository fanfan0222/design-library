. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Codex'; tier='first'; source='Codex desktop (process ChatGPT)'; privacy='Settings may show account/email/paths; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'ChatGPT'
function Open-Settings { $b = Find-All $w '打开个人资料菜单' 'Button' | Select -First 1; [void](Click-El $b); Start-Sleep 1.2; $mi = Find-Root-All '设置 Ctrl+,' 'MenuItem' | Select -First 1; [void](Click-El $mi); Start-Sleep 2.5 }
function NavBtn($k) { Find-All $w $k 'Button' | ? { $r=$_.Current.BoundingRectangle; $r.X -gt 100 -and $r.X -lt 200 -and $r.Width -gt 400 } | Select -First 1 }
Open-Settings
$map = [ordered]@{ '外观'='appearance'; '账户'='account'; 'Archived chats'='archived-chats'; '广告设置'='ads'; '家长控制'='parental-controls'; '受信任联系人'='trusted-contacts'; '语音'='voice'; '配置'='config'; '个性化'='personalization'; 'Mini 与虚拟宠物'='mini-pet'; '键盘快捷键'='shortcuts'; '使用情况和计费'='usage-billing'; '数据管理'='data-controls'; '插件'='plugins'; '电脑操控'='computer-use'; '应用快照'='app-snapshots'; '浏览器'='browser'; '云电脑'='cloud-computer'; '钩子'='hooks'; '连接'='connections'; '云端偏好设置'='cloud-preferences'; '代码审查'='code-review'; 'Git'='git'; '环境'='environments'; 'Worktrees'='worktrees' }
$integ = '插件','电脑操控','应用快照','浏览器','云电脑'; $code = '钩子','连接','云端偏好设置','代码审查','Git','环境','Worktrees'
foreach ($k in $map.Keys) {
  $b = NavBtn $k; if (-not $b) { Open-Settings; $b = NavBtn $k }
  if (-not $b) { "MISSING $k"; continue }
  try { $b.GetCurrentPattern([System.Windows.Automation.ScrollItemPattern]::Pattern).ScrollIntoView(); Start-Sleep -Milliseconds 400 } catch {}
  $how = Click-El $b; Start-Sleep 2.2
  $g = if ($integ -contains $k) { '集成' } elseif ($code -contains $k) { '编码' } else { '个人' }
  $still = NavBtn '常规'
  $note = if ($still) { "Codex 设置 - $k，仅查看未改值" } else { "点击设置「$k」后跳出设置页（独立页面/弹层）" }
  Save-Shot 'codex' ("settings-" + $map[$k]) (M @{ tags=@('settings-page','section-nav','form-rows','restrained'); layout="full-page settings: left grouped section list + right form ($k)"; nav="settings nav [$g] -> $k"; clicks=@('Button 打开个人资料菜单','MenuItem 设置 Ctrl+, (Invoke)',"Button $k ($how)"); notes=$note })
  if (-not $still) { "LEFT-SETTINGS after $k"; Press-Esc }
}
"SKIPPED 密码 (privacy)"