. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'Grok Bot'
$b = Find-All $w '新建聊天' 'Button' | Select -First 1; $how = Click-El $b; Start-Sleep 2.5
Save-Shot 'grok-bot' 'new-chat-empty' @{ app='Grok Bot'; tier='first'; source='Grok Bot desktop'; tags=@('empty-state','recipient-picker','composer','restrained','light-density'); layout='sidebar + blank canvas with 收件人 picker top + bottom composer'; nav='sidebar 新建聊天 button'; clicks=@("Button 新建聊天 ($how)"); notes='新建聊天空态（收件人：Start a chat with...），未发送消息'; privacy='Sidebar conversation titles visible.' }
$r = Find-All $w '前端审美库助手, 工作中' 'Button' | Select -First 1
if (-not $r) { $r = Find-All $w '前端审美库助手' 'Button' | Select -First 1 }
if ($r) { "return: " + (Click-El $r) }