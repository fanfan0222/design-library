. F:\project\design-library\scripts\opencli-lib.ps1
$A='ChatGPT Web'; $G='chatgpt-web'
function Esc { OC keys Escape | Out-Null; OCw 1 }
# ensure settings open
$u = OCurl
if ($u -notmatch 'settings') {
  OC open https://chatgpt.com/ | Out-Null; OCw 3
  OC click --role button --name 'Open profile menu' --nth 1 | Out-Null; OCw 1.5
  OC click --role menuitem --name 'Settings' | Out-Null; OCw 2.5
}
Snap $G $A settings-general '设置 · General' @('settings-modal','tabbed-settings','left-tab-rail') 'settings: left rail + form' 'Settings > General' @('Settings') ''
$secs = @(
  @('settings-appearance','Appearance'),
  @('settings-notifications','Notifications'),
  @('settings-profile','Profile'),
  @('settings-security','Security and login'),
  @('settings-account','Account'),
  @('settings-archived','Archived chats'),
  @('settings-parental','Parental controls'),
  @('settings-trusted-contact','Trusted contact'),
  @('settings-voice','Voice'),
  @('settings-storage','Storage'),
  @('settings-personalization','Personalization'),
  @('settings-pets','Pets'),
  @('settings-keyboard','Keyboard'),
  @('settings-usage','Usage'),
  @('settings-billing','Billing'),
  @('settings-data-controls','Data controls'),
  @('settings-plugins','Plugins'),
  @('settings-passwords','Passwords'),
  @('settings-cloud-computer','Cloud computer'),
  @('settings-code-review','Code Review')
)
foreach ($sec in $secs) {
  $slug=$sec[0]; $label=$sec[1]
  $out = OC click --role button --name $label 2>$null | Out-String
  if ($out -notmatch '"clicked"\s*:\s*true' -and $out -notmatch 'matches_n.: [1-9]') {
    Write-Host "RETRY-TEXT $label"
    OC click --text $label | Out-Null
  }
  OCw 2
  Snap $G $A $slug ("设置 · $label") @('settings-modal','tabbed-settings') 'settings section' "Settings > $label" @("click $label") "UI study only; no secrets in meta"
}
# settings search focus
OC click --role searchbox --name 'Search' | Out-Null; OCw 1
Snap $G $A settings-search '设置 · 搜索框' @('settings-modal','search') 'settings search focused' 'Settings > Search' @('click Search settings') ''
Esc; Esc
OC open https://chatgpt.com/ | Out-Null; OCw 2
'DONE-SETTINGS-ALL'