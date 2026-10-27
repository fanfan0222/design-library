. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Codex'; tier='first'; source='Codex desktop (process ChatGPT)'; privacy='Settings may show account/email/paths; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'ChatGPT'
$map = [ordered]@{ '常规'='general'; '通知'='notifications'; '导入'='import'; '个人资料'='profile'; '外观'='appearance'; '账户'='account'; 'Archived chats'='archived-chats'; '广告设置'='ads'; '家长控制'='parental-controls'; '受信任联系人'='trusted-contacts'; '语音'='voice'; '配置'='config'; '个性化'='personalization'; 'Mini 与虚拟宠物'='mini-pet'; '键盘快捷键'='shortcuts'; '使用情况和计费'='usage-billing'; '数据管理'='data-controls'; '插件'='plugins'; '电脑操控'='computer-use'; '应用快照'='app-snapshots'; '浏览器'='browser'; '云电脑'='cloud-computer'; '钩子'='hooks'; '连接'='connections'; '云端偏好设置'='cloud-preferences'; '代码审查'='code-review'; 'Git'='git'; '环境'='environments'; 'Worktrees'='worktrees' }
$groups = @{ '插件'='集成'; '电脑操控'='集成'; '应用快照'='集成'; '浏览器'='集成'; '云电脑'='集成'; '钩子'='编码'; '连接'='编码'; '云端偏好设置'='编码'; '代码审查'='编码'; 'Git'='编码'; '环境'='编码'; 'Worktrees'='编码' }
foreach ($k in $map.Keys) {
  $b = Find-All $w $k 'Button' | ? { $r=$_.Current.BoundingRectangle; $r.X -gt 100 -and $r.X -lt 200 -and $r.Width -gt 400 } | Select -First 1
  if (-not $b) { "MISSING $k"; continue }
  try { $b.GetCurrentPattern([System.Windows.Automation.ScrollItemPattern]::Pattern).ScrollIntoView() } catch {}
  $how = Click-El $b; Start-Sleep 2.2
  $g = if ($groups[$k]) { $groups[$k] } else { '个人' }
  Save-Shot 'codex' ("settings-" + $map[$k]) (M @{ tags=@('settings-page','section-nav','form-rows','restrained'); layout="full-page settings: left grouped section list + right form ($k)"; nav="settings nav [$g] -> $k"; clicks=@('Button 打开个人资料菜单','MenuItem 设置 Ctrl+, (Invoke)',"Button $k ($how)"); notes="Codex 设置 - $k，仅查看未改值" })
}
"SKIPPED 密码 (privacy: may list saved credentials)"