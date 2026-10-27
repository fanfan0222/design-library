. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
$mi = Find-Root-All '设置 Ctrl+,' 'MenuItem' | Select -First 1
if (-not $mi) { $b = Find-All $w '打开个人资料菜单' 'Button' | Select -First 1; [void](Click-El $b); Start-Sleep 1.2; $mi = Find-Root-All '设置 Ctrl+,' 'MenuItem' | Select -First 1 }
"settings: " + (Click-El $mi); Start-Sleep 3
Dump-Names $w @('Button','TabItem','ListItem','Hyperlink','Text') | ? { $_ -notmatch '^Text\t.{50,}' } | Select -First 90