. F:\project\design-library\scripts\uia-lib.ps1
$base = @{ app='Codex'; tier='first'; source='Codex desktop (process ChatGPT, window title ChatGPT)'; privacy='Sidebar shows real chat titles; redact before sharing.' }
function M($h) { $r = $base.Clone(); foreach ($k in $h.Keys) { $r[$k] = $h[$k] }; $r }
$w = Focus-App 'ChatGPT'
Save-Shot 'codex' 'main' (M @{ tags=@('icon-rail','sidebar','hero-composer','empty-state','restrained'); layout='left icon rail + chat/project sidebar + centered hero prompt 我们要构建什么？ + composer'; nav='icon rail 首页/图像/定时任务/资料库/插件/探索/代码审查'; clicks=@('focus+maximize; 首页'); notes='Codex 模式首页' })
$nav = [ordered]@{ '图像'='images'; '定时任务'='scheduled-tasks'; '资料库'='library'; '插件'='plugins'; '探索'='explore'; '代码审查'='code-review' }
foreach ($k in $nav.Keys) {
  $b = Find-All $w $k 'Button' | ? { $_.Current.BoundingRectangle.X -lt 100 } | Select -First 1
  if (-not $b) { "MISSING $k"; continue }
  $how = Click-El $b; Start-Sleep 3
  "--- $k"; Dump-Names $w @('Text') | ? { $_ -match '\t(\d+),' -and [int]$matches[1] -gt 700 } | Select -First 8
  Save-Shot 'codex' $nav[$k] (M @{ tags=@('icon-rail','sidebar','content-page','restrained'); layout="icon rail + $k page"; nav="icon rail -> $k"; clicks=@("Button $k ($how)"); notes="Codex 左侧导航「$k」页面" })
}
$b = Find-All $w '首页' 'Button' | ? { $_.Current.BoundingRectangle.X -lt 100 } | Select -First 1; [void](Click-El $b); Start-Sleep 2