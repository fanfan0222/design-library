. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Codex'; tier='first'; source='Codex desktop (process ChatGPT)'; privacy='Sidebar shows real chat titles; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
function Rail($n) { Find-All $w $n 'Button' | ? { $_.Current.BoundingRectangle.X -lt 100 } | Select -First 1 }
$w = Focus-App 'ChatGPT'
Press-Esc; [void](Click-El (Rail '首页')); Start-Sleep 2
# more menu
$how = Click-El (Rail '探索'); Start-Sleep 1.5
"--- more menu"; Dump-Names $AE::RootElement @('MenuItem') | Select -First 10
Save-Shot 'codex' 'more-menu' (M @{ tags=@('popover-menu','icon-rail','restrained'); layout='icon rail overflow popover (项目/地图/代码审查)'; nav='icon rail ··· (UIA name 探索)'; clicks=@("Button 探索 ($how)"); notes='侧栏「更多」弹出菜单' })
Press-Esc; [void](Click-El (Rail '首页')); Start-Sleep 2
# mode menu
$b = Find-All $w '切换模式，当前模式：Codex' 'Button' | Select -First 1
if ($b) { $how = Click-El $b; Start-Sleep 1.5; "--- mode"; Dump-Names $AE::RootElement @('MenuItem','RadioButton') | Select -First 10
  Save-Shot 'codex' 'mode-switcher' (M @{ tags=@('dropdown','mode-switch','restrained'); layout='sidebar header dropdown: ChatGPT / Codex modes'; nav='sidebar header'; clicks=@("Button 切换模式 ($how)"); notes='模式切换下拉（未切换）' }); Press-Esc }
# search
$b = Find-All $w '搜索' 'Button' | ? { $_.Current.BoundingRectangle.X -gt 400 -and $_.Current.BoundingRectangle.X -lt 700 } | Select -First 1
if ($b) { $how = Click-El $b; Start-Sleep 1.5; Save-Shot 'codex' 'search' (M @{ tags=@('command-palette','search','overlay'); layout='search overlay'; nav='sidebar header 搜索'; clicks=@("Button 搜索 ($how)"); notes='聊天搜索' }); Press-Esc; Press-Esc }
# activity
$b = Find-All $w '查看活动' 'Button' | Select -First 1
if ($b) { $how = Click-El $b; Start-Sleep 2; Save-Shot 'codex' 'activity' (M @{ tags=@('panel','activity-feed','restrained'); layout='activity view'; nav='sidebar header 查看活动'; clicks=@("Button 查看活动 ($how)"); notes='活动/任务进度视图' }); Press-Esc }
[void](Click-El (Rail '首页')); Start-Sleep 1.5
# chat view
$b = Find-All $w '安装 Cursor' 'Button' | Select -First 1
if ($b) { $how = Click-El $b; Start-Sleep 3; Save-Shot 'codex' 'chat-thread' (M @{ tags=@('chat','thread','agent-steps','restrained'); layout='icon rail + sidebar + conversation thread with agent tool steps + composer'; nav='sidebar 最近 -> chat'; clicks=@("Button 安装 Cursor ($how)"); notes='已有会话对话态（含 Agent 执行步骤）'; privacy='Shows real conversation content.' }) }
# profile menu
$b = Find-All $w '打开个人资料菜单' 'Button' | Select -First 1
$how = Click-El $b; Start-Sleep 1.5
"--- profile menu"; Dump-Names $AE::RootElement @('MenuItem') | Select -First 15
Save-Shot 'codex' 'profile-menu' (M @{ tags=@('popover-menu','account'); layout='popover above avatar bottom-left'; nav='icon rail avatar'; clicks=@("Button 打开个人资料菜单 ($how)"); notes='个人资料菜单'; privacy='May show account email.' })