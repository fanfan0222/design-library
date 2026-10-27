. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
$h = Find-All $w '首页' 'Button' | ? { $_.Current.BoundingRectangle.X -lt 100 } | Select -First 1; Mouse-Click $h | Out-Null; Mouse-Away