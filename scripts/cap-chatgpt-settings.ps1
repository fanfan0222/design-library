. F:\project\design-library\scripts\opencli-lib.ps1
$A='ChatGPT Web'; $G='chatgpt-web'
function Home { OC open https://chatgpt.com/ | Out-Null; OCw 4 }
function Esc { OC keys Escape | Out-Null; OCw 1 }
function OpenSettings {
  Home
  OC click --role button --name 'Open profile menu' | Out-Null; OCw 1.5
  # Settings may be menuitem or button
  $r = OC click --role menuitem --name 'Settings' 2>$null
  if (-not $r -or ($r -match 'matches_n.: 0')) {
    OC click --text 'Settings' | Out-Null
  }
  OCw 2.5
}
OpenSettings
Snap $G $A settings-general '设置 · 常规' @('settings-modal','tabbed-settings','left-tab-rail','form-rows') 'centered settings modal: left section rail + right form' 'Profile > Settings > General' @('Open profile menu','Settings') 'General settings'
# discover left rail labels via state
$st = OC state 2>$null | Out-String
# Known ChatGPT settings sections (EN labels)
$secs = @(
  @('settings-general','General'),
  @('settings-notifications','Notifications'),
  @('settings-personalization','Personalization'),
  @('settings-apps-connectors','Apps & Connectors'),
  @('settings-data-controls','Data controls'),
  @('settings-security','Security'),
  @('settings-account','Account'),
  @('settings-parental','Parental controls'),
  @('settings-usage','Usage'),
  @('settings-appearance','Appearance'),
  @('settings-passwords','Password'),
  @('settings-builder-profile','Builder profile'),
  @('settings-voice','Voice'),
  @('settings-archived','Archived chats'),
  @('settings-memory','Memory')
)
foreach ($sec in $secs) {
  $slug=$sec[0]; $label=$sec[1]
  # try button then text then menuitem
  $ok=$false
  foreach ($mode in @('button','text','menuitem')) {
    if ($mode -eq 'text') { $out = OC click --text $label 2>$null | Out-String }
    elseif ($mode -eq 'button') { $out = OC click --role button --name $label 2>$null | Out-String }
    else { $out = OC click --role menuitem --name $label 2>$null | Out-String }
    if ($out -match '"clicked"\s*:\s*true' -or $out -match 'matches_n.: [1-9]') { $ok=$true; break }
  }
  if (-not $ok) { Write-Host "SKIP $slug ($label)"; continue }
  OCw 2
  Snap $G $A $slug ("设置 · $label") @('settings-modal','tabbed-settings','form-rows') 'settings modal section' "Settings > $label" @("click $label") "Settings section $label — no secrets recorded"
}
Esc; Esc
Home
# model picker if present
$out = OC click --role button --name 'Model' 2>$null | Out-String
if ($out -notmatch 'matches_n.: 0') { OCw 1.5; Snap $G $A model-picker '模型选择器' @('model-picker','dropdown') 'header/model dropdown' 'Model picker' @('click Model') ''; Esc }
# composer mode Chat again
'DONE-SETTINGS'