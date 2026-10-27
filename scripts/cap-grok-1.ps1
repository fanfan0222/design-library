. F:\project\design-library\scripts\uia-lib.ps1
$priv = 'Contains real chat history / sidebar conversation titles; redact before sharing externally.'
$base = @{ app='Grok Bot'; tier='first'; source='Grok Bot desktop (process "Grok Bot")'; privacy=$priv }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'Grok Bot'
# details panel is open -> capture details tabs first
$t = Find-All $w '详情' 'TabItem' | Select -First 1; $how = Click-El $t; Start-Sleep 1
Save-Shot 'grok-bot' 'details-info-tab' (M @{ tags=@('three-pane','details-drawer','profile-card','restrained'); layout='sidebar + chat + right details drawer (详情 tab)'; nav='right drawer tabs 详情/资料库/电脑'; clicks=@("Button 查看对话详情 (Expand)","TabItem 详情 ($how)"); notes='Bot 头像/名称/标签 + 详情信息' })
$t = Find-All $w '资料库' 'TabItem' | Select -First 1; $how = Click-El $t; Start-Sleep 1.5
Save-Shot 'grok-bot' 'details-media-tab' (M @{ tags=@('three-pane','details-drawer','media-grid','restrained'); layout='sidebar + chat + right drawer 资料库 tab (files/media)'; nav='right drawer tabs'; clicks=@("Button 查看对话详情 (Expand)","TabItem 资料库 ($how)"); notes='对话内产出的图片/文件资料库' })
$t = Find-All $w '电脑' 'TabItem' | Select -First 1; $how = Click-El $t; Start-Sleep 1.5
Save-Shot 'grok-bot' 'details-computer-tab' (M @{ tags=@('three-pane','details-drawer','machine-status','restrained'); layout='sidebar + chat + right drawer 电脑 tab'; nav='right drawer tabs'; clicks=@("Button 查看对话详情 (Expand)","TabItem 电脑 ($how)"); notes='Bot 云电脑 / 本地机器状态面板' })
$t = Find-All $w '详情' 'TabItem' | Select -First 1; [void](Click-El $t)
# close drawer
$c = Find-All $w '关闭' 'Button' | ? { $_.Current.BoundingRectangle.Y -gt 5 } | Select -First 1
if ($c) { "close: " + (Click-El $c) }; Start-Sleep 1.5
Save-Shot 'grok-bot' 'main' (M @{ tags=@('two-pane','sidebar','chat','restrained','light-density'); layout='left conversation sidebar + centered chat column + bottom composer'; nav='left sidebar (搜索/新建聊天/会话列表/账户菜单)'; clicks=@('focus+maximize only'); notes='首选参考族：侧栏+对话+轻量信息密度' })