# cap-batch-web.ps1 — OpenCLI navigate + physical 4K via uia-lib Save-Shot
$ErrorActionPreference = 'Continue'
. F:\project\design-library\scripts\web-lib.ps1
$script:S = 'designlib'
$env:NO_UPDATE_NOTIFIER = '1'
function OC { & opencli browser $script:S @args 2>$null }
function OCw([double]$s=2){ Start-Sleep -Milliseconds ([int]($s*1000)) }
function OCurl {
  $r = (OC eval 'location.href' | Out-String).Trim().Trim('"')
  return $r
}
function OCTitle {
  $t = (OC get title | Out-String)
  return ($t -split "`n" | Where-Object { $_.Trim() -and $_ -notmatch 'Update available|npm install|^\s*$' } | Select-Object -First 1)
}
function Cap4K([string]$slug,[string]$app,[string]$screen,[string]$title,[string[]]$tags,[string]$layout,[string]$nav,[string[]]$clicks,[string]$notes,[bool]$loggedIn) {
  Chrome-ToPrimary
  Focus-Chrome | Out-Null
  $url = OCurl
  $meta = @{
    app=$app; tier='first'; tags=$tags; layout=$layout; nav=$nav
    source='User Chrome on fanfan via OpenCLI + physical 4K fullscreen'
    clicks=$clicks; notes=$notes
    privacy='May show account/UI; redact before external share.'
    url=$url
  }
  $r = Save-Shot $slug $screen $meta
  # patch meta for web fields
  $mp = Join-Path $script:Root "apps\$slug\$screen\meta.json"
  $m = Get-Content -Raw -Encoding UTF8 $mp | ConvertFrom-Json
  $m | Add-Member -NotePropertyName title -NotePropertyValue $title -Force
  $m | Add-Member -NotePropertyName platform -NotePropertyValue 'web' -Force
  $m | Add-Member -NotePropertyName tool -NotePropertyValue 'opencli+uia-lib' -Force
  $m | Add-Member -NotePropertyName url -NotePropertyValue $url -Force
  $m | Add-Member -NotePropertyName logged_in -NotePropertyValue $loggedIn -Force
  $m | Add-Member -NotePropertyName machine -NotePropertyValue 'fanfan' -Force
  $m | Add-Member -NotePropertyName style_doc -NotePropertyValue 'STYLE-GUIDE.md' -Force
  $m | Add-Member -NotePropertyName browser -NotePropertyValue 'Google Chrome, maximized, physical 4K' -Force
  [IO.File]::WriteAllText($mp, ($m | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  Write-Host $r
  return $true
}

$log = New-Object System.Collections.Generic.List[string]
function Log([string]$s){ $log.Add($s); Write-Host $s }

# --- Claude: login only ---
OC open 'https://claude.ai/login' | Out-Null; OCw 4
Cap4K 'claude-web' 'Claude Web' 'login' '登录页' @('login','auth-wall','marketing-shell') 'centered auth on brand shell' 'claude.ai/login' @('open claude.ai → redirected /login') 'Bridge profile not logged in; login wall only.' $false
Log 'CAPTURED claude-web/login (skip deeper: not logged in)'

# --- Perplexity ---
OC open 'https://www.perplexity.ai/' | Out-Null; OCw 5
$pt = OCTitle; $pu = OCurl
$ptext = (OC eval "(document.body.innerText||'').slice(0,800)" | Out-String)
$plogged = $ptext -notmatch '(?i)sign in|log in|get started' -or $ptext -match '(?i)library|spaces|settings|new thread|ask anything'
# softer heuristic: state interactive names
$pst = (OC state | Out-String)
$plogged2 = $pst -match '(?i)Library|Spaces|Settings|New Thread|Account|Profile' -and $pst -notmatch '(?i)Sign in to Perplexity'
Log "PERPLEXITY url=$pu title=$pt loggedHint=$plogged2"
Cap4K 'perplexity-web' 'Perplexity' 'home' '首页/搜索' @('search-home','centered-composer','ai-answer') 'centered search hero / home' 'perplexity.ai/' @('open perplexity.ai') "title=$pt" $plogged2

# try spaces
OC open 'https://www.perplexity.ai/spaces' | Out-Null; OCw 4
$su = OCurl; $st = OCTitle
if ($su -match 'login|signin' -or $st -match '(?i)sign in|log in') {
  Log "SKIP perplexity-web/spaces reason=login wall url=$su"
} else {
  Cap4K 'perplexity-web' 'Perplexity' 'spaces' 'Spaces' @('spaces','collection','sidebar') 'spaces list/grid' 'perplexity.ai/spaces' @('open /spaces') "title=$st" $true
  Log 'CAPTURED perplexity-web/spaces'
}

# try settings
OC open 'https://www.perplexity.ai/settings/account' | Out-Null; OCw 4
$su = OCurl; $st = OCTitle
if ($su -match 'login|signin' -or $st -match '(?i)sign in|log in') {
  Log "SKIP perplexity-web/settings reason=login wall url=$su"
} else {
  Cap4K 'perplexity-web' 'Perplexity' 'settings-account' '设置-账户' @('settings','form','account') 'settings page' '/settings/account' @('open /settings/account') "title=$st" $true
  Log 'CAPTURED perplexity-web/settings-account'
}

# home again + try account menu if any
OC open 'https://www.perplexity.ai/' | Out-Null; OCw 3
OC click --role button --name 'Account' 2>$null | Out-Null; OCw 1.5
$pst2 = (OC state | Out-String)
if ($pst2 -match '(?i)Sign out|Log out|Settings|Upgrade') {
  Cap4K 'perplexity-web' 'Perplexity' 'account-menu' '账户菜单' @('popover-menu','account') 'account popover' 'Account button' @('click Account') '' $true
  Log 'CAPTURED perplexity-web/account-menu'
  OC keys Escape | Out-Null
} else {
  Log 'SKIP perplexity-web/account-menu reason=no account menu visible (likely guest)'
}

# --- v0 ---
OC open 'https://v0.dev' | Out-Null; OCw 5
$vu = OCurl; $vt = OCTitle
Cap4K 'v0-web' 'v0' 'home' '首页/工作台' @('generative-ide','canvas','marketing-or-app') 'v0 main shell' $vu @('open v0.dev') "title=$vt final=$vu" ($vu -notmatch 'login|signin')
Log "CAPTURED v0-web/home url=$vu"

# settings if possible
OC open 'https://v0.app/chat' | Out-Null; OCw 4
$vu2 = OCurl; $vt2 = OCTitle
if ($vu2 -match 'login|signin|signup') {
  Log "SKIP v0-web/chat reason=auth url=$vu2"
} else {
  Cap4K 'v0-web' 'v0' 'chat' '对话/生成工作台' @('chat','generative-ide') 'chat workspace' $vu2 @('open v0.app/chat') "title=$vt2" $true
  Log "CAPTURED v0-web/chat"
}

# --- Lovable ---
OC open 'https://lovable.dev' | Out-Null; OCw 5
$lu = OCurl; $lt = OCTitle
Cap4K 'lovable-web' 'Lovable' 'home' '首页' @('marketing','app-builder','hero') 'lovable landing/home' $lu @('open lovable.dev') "title=$lt" ($lu -notmatch 'login|signin')
Log "CAPTURED lovable-web/home"

OC open 'https://lovable.dev/dashboard' | Out-Null; OCw 5
$lu2 = OCurl; $lt2 = OCTitle
if ($lu2 -match 'login|signin|signup|auth') {
  Log "SKIP lovable-web/dashboard reason=auth url=$lu2"
} else {
  Cap4K 'lovable-web' 'Lovable' 'dashboard' '项目面板' @('dashboard','projects','grid') 'projects dashboard' $lu2 @('open /dashboard') "title=$lt2" $true
  Log 'CAPTURED lovable-web/dashboard'
}

# --- Cursor Web ---
OC open 'https://cursor.com' | Out-Null; OCw 5
$cu = OCurl; $ct = OCTitle
Cap4K 'cursor-web' 'Cursor Web' 'home' '官网首页' @('marketing','product-home') 'cursor.com marketing/home' $cu @('open cursor.com') "title=$ct" $true
Log "CAPTURED cursor-web/home url=$cu"

OC open 'https://cursor.com/agents' | Out-Null; OCw 4
$cu2 = OCurl; $ct2 = OCTitle
if ($cu2 -match 'login|signin') {
  Log "SKIP cursor-web/agents reason=auth url=$cu2"
} else {
  Cap4K 'cursor-web' 'Cursor Web' 'agents' 'Agents' @('agents','product-shell') 'agents product page' $cu2 @('open /agents') "title=$ct2" $true
  Log 'CAPTURED cursor-web/agents'
}

# --- Cursor Desktop (UIA) ---
try {
  $cw = Focus-App 'Cursor'
  if ($cw) {
    Start-Sleep 1
    $meta = @{
      app='Cursor'; tier='first'; tags=@('desktop','agents','ide-shell'); layout='Cursor Agents desktop window maximized'
      nav='already open Cursor Agents'; source='Cursor desktop on fanfan via UIA Focus-App'
      clicks=@('Focus-App Cursor + maximize'); notes='Window title was Cursor Agents'; privacy='May show project/agent names'
    }
    $r = Save-Shot 'cursor' 'agents-main' $meta
    $mp = Join-Path $script:Root 'apps\cursor\agents-main\meta.json'
    $m = Get-Content -Raw -Encoding UTF8 $mp | ConvertFrom-Json
    $m | Add-Member -NotePropertyName title -NotePropertyValue 'Agents 主界面' -Force
    $m | Add-Member -NotePropertyName style_doc -NotePropertyValue 'STYLE-GUIDE.md' -Force
    $m | Add-Member -NotePropertyName machine -NotePropertyValue 'fanfan' -Force
    [IO.File]::WriteAllText($mp, ($m | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
    Log "CAPTURED cursor/agents-main :: $r"
  } else {
    Log 'SKIP cursor/agents-main reason=Focus-App returned null'
  }
} catch {
  Log "SKIP cursor desktop reason=$($_.Exception.Message)"
}

$log | Set-Content "F:\project\design-library\_cap_log.txt" -Encoding UTF8
Write-Host '==== LOG ===='; $log
Write-Host 'DONE-BATCH'
