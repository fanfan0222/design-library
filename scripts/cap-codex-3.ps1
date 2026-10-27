. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
$b = Find-All $w '整理桌面文件归档' 'Button' | Select -First 1
$how = Click-El $b; Start-Sleep 4
Save-Shot 'codex' 'chat-thread' @{ app='Codex'; tier='first'; source='Codex desktop (process ChatGPT)'; tags=@('chat','thread','agent-steps','restrained'); layout='icon rail + sidebar + conversation thread with agent tool steps + composer'; nav='sidebar 最近 -> chat'; clicks=@("Button 整理桌面文件归档 ($how)"); notes='已有本地会话对话态（灰色条目为不可打开的云端/其他设备会话，点击无反应）'; privacy='Shows real conversation content (desktop file names).' }