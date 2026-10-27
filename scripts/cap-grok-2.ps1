. F:\project\design-library\scripts\uia-lib.ps1
$priv = 'Account menu/settings show account name & email; chat history visible behind. Redact before sharing.'
$base = @{ app='Grok Bot'; tier='first'; source='Grok Bot desktop'; privacy=$priv }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'Grok Bot'
$b = Find-All $w '打开账户菜单' 'Button' | Select -First 1; $how = Click-El $b; Start-Sleep 1.2
"--- menu items"
Dump-Names $AE::RootElement @('MenuItem') 
Save-Shot 'grok-bot' 'account-menu' (M @{ tags=@('popover-menu','account','restrained'); layout='popover menu anchored bottom-left above account button'; nav='account menu'; clicks=@("Button 打开账户菜单 ($how)") ; notes='账户弹出菜单'})
$mi = Find-Root-All '设置' 'MenuItem' | Select -First 1; $how2 = Click-El $mi; Start-Sleep 2
"--- settings window controls"
$sw = $AE::RootElement.FindAll($TS::Children, [System.Windows.Automation.Condition]::TrueCondition) | ? { $_.Current.Name -like '*设置*' }
$sw | % { "WIN: " + $_.Current.Name + " / " + $_.Current.ClassName }
Dump-Names $w @('Button','TabItem','ListItem','Hyperlink','Text','Window') | ? { $_ -notmatch '^Text\t.{40,}' } | Select -Last 80
Save-Shot 'grok-bot' 'settings' (M @{ tags=@('settings-dialog','modal','form-controls','restrained'); layout='centered modal settings over dimmed chat; left section nav + right form'; nav='settings section nav'; clicks=@("Button 打开账户菜单 ($how)","MenuItem 设置 ($how2)"); notes='默认（通用）设置分区，仅查看未改值'})