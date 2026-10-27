. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Grok Bot'; tier='first'; source='Grok Bot desktop'; privacy='Sidebar conversation titles/previews visible; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'Grok Bot'
$b = Find-All $w '搜索' 'Button' | Select -First 1; $how = Click-El $b; Start-Sleep 1.5
"--- after search"; Dump-Names $AE::RootElement @('Edit','Window','Dialog') | Select -First 15
Save-Shot 'grok-bot' 'sidebar-search' (M @{ tags=@('command-palette','search','overlay','restrained'); layout='search overlay/palette'; nav='sidebar 搜索 button'; clicks=@("Button 搜索 ($how)"); notes='会话搜索 UI' })
Press-Esc; Press-Esc; Start-Sleep 1
$b = Find-All $w '新建聊天' 'Button' | Select -First 1; $how = Click-El $b; Start-Sleep 2
"--- after new chat"; Dump-Names $w @('Edit','Button','Text') | ? { $_ -match '\t(\d+),' -and [int]$matches[1] -gt 420 } | Select -First 30
Save-Shot 'grok-bot' 'new-chat-empty' (M @{ tags=@('empty-state','hero-composer','restrained','light-density'); layout='sidebar + centered empty state with composer'; nav='sidebar 新建聊天 button'; clicks=@("Button 新建聊天 ($how)"); notes='新建聊天空态，未发送消息' })
$r = Find-All $w '前端审美库助手, 工作中' 'Button' | Select -First 1
if (-not $r) { $r = Find-All $w '前端审美库助手' 'Button' | Select -First 1 }
if ($r) { "return: " + (Click-El $r) } else { "could not find return chat" }