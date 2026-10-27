# cap-claude-deep + google login others
$ErrorActionPreference='Continue'
. F:\project\design-library\scripts\web-lib.ps1
$script:S='designlib'
$env:NO_UPDATE_NOTIFIER='1'
function OC { & opencli browser $script:S @args 2>$null }
function OCg { & opencli browser gauth @args 2>$null }
function OCw([double]$s=2){ Start-Sleep -Milliseconds ([int]($s*1000)) }
function OCurl { ((OC eval 'location.href')|Out-String).Trim().Trim('"') }
$log = New-Object System.Collections.Generic.List[string]
function Log([string]$s){ $log.Add($s); Write-Host $s }

function Cap4K([string]$slug,[string]$app,[string]$screen,[string]$title,[string[]]$tags,[string]$layout,[string]$nav,[string[]]$clicks,[string]$notes,[bool]$loggedIn) {
  Chrome-ToPrimary; Focus-Chrome | Out-Null
  $url = OCurl
  $meta = @{ app=$app; tier='first'; tags=$tags; layout=$layout; nav=$nav; source='User Chrome fanfan OpenCLI+4K'; clicks=$clicks; notes=$notes; privacy='May show account/UI; redact before external.'; url=$url }
  $r = Save-Shot $slug $screen $meta
  $mp = Join-Path $script:Root "apps\$slug\$screen\meta.json"
  $m = Get-Content -Raw -Encoding UTF8 $mp | ConvertFrom-Json
  $m | Add-Member title $title -Force
  $m | Add-Member platform 'web' -Force
  $m | Add-Member tool 'opencli+uia-lib' -Force
  $m | Add-Member url $url -Force
  $m | Add-Member logged_in $loggedIn -Force
  $m | Add-Member machine 'fanfan' -Force
  $m | Add-Member style_doc 'STYLE-GUIDE.md' -Force
  $m | Add-Member browser 'Chrome maximized physical 4K' -Force
  [IO.File]::WriteAllText($mp, ($m|ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  Log "CAP $slug/$screen :: $r"
}

function Focus-Title([string]$sub) {
  if (-not ('WinFocus3' -as [type])) {
    Add-Type @"
using System; using System.Text; using System.Runtime.InteropServices;
public class WinFocus3 {
  public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc lpEnumFunc, IntPtr lParam);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  public static IntPtr FindTitle(string sub) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      if (!IsWindowVisible(h)) return true;
      var sb = new StringBuilder(512); GetWindowText(h, sb, 512);
      if (sb.ToString().IndexOf(sub, StringComparison.OrdinalIgnoreCase) >= 0) { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
}
"@
  }
  $h = [WinFocus3]::FindTitle($sub)
  if ($h -eq [IntPtr]::Zero) { return $false }
  [void][WinFocus3]::ShowWindow($h, 9)
  [W32]::keybd_event(0x12,0,0,[IntPtr]::Zero); [W32]::keybd_event(0x12,0,2,[IntPtr]::Zero)
  [void][WinFocus3]::SetForegroundWindow($h)
  Start-Sleep 1
  return $true
}

function Try-GoogleLogin([string]$label, [scriptblock]$startClick) {
  Log "GOOGLE-LOGIN start $label"
  & $startClick
  OCw 3
  # look for Google accounts popup
  $ok = Focus-Title 'Google accounts'
  if (-not $ok) { $ok = Focus-Title 'Sign in' }
  if (-not $ok) {
    Log "SKIP google-login $label reason=no Google accounts popup"
    return $false
  }
  opencli browser gauth unbind 2>$null | Out-Null
  opencli browser gauth bind 2>$null | Out-Null
  OCw 1
  $gu = ((OCg eval 'location.href')|Out-String)
  if ($gu -notmatch 'accounts.google.com') {
    Log "SKIP google-login $label reason=bind not on accounts.google.com ($gu)"
    return $false
  }
  # choose first account if chooser
  $st = (OCg state | Out-String)
  if ($st -match 'Choose an account' -or $st -match 'fanfan') {
    OCg click --text 'fanfan' 2>$null | Out-Null
    OCw 1
    # prefer click on account row via eval
    OCg eval "const el=[...document.querySelectorAll('div[role=link],li div')].find(e=>/fanfan|qwe1174740998/i.test(e.innerText||'')); if(el){el.click();'ok'} else 'none'" 2>$null | Out-Null
    OCw 3
  }
  # Continue on consent
  for ($i=0;$i -lt 3;$i++) {
    $r = (OCg click --role button --name 'Continue' 2>&1 | Out-String)
    if ($r -match '"clicked": true') { OCw 4; break }
    $r = (OCg click --role button --name 'Allow' 2>&1 | Out-String)
    if ($r -match '"clicked": true') { OCw 4; break }
    OCw 1
  }
  Log "GOOGLE-LOGIN done $label (popup may have closed)"
  # re-focus main chrome
  Focus-Title 'Claude' | Out-Null
  if (-not (Focus-Title 'Claude')) { Focus-Title 'Chrome' | Out-Null }
  # rebind designlib if needed
  $du = OCurl
  if ($du -match 'about:blank' -or -not $du) {
    Focus-Title 'Gemini' | Out-Null
    if (-not (Focus-Title 'Gemini')) { Focus-Title 'Chrome' | Out-Null }
    opencli browser designlib unbind 2>$null | Out-Null
    opencli browser designlib bind 2>$null | Out-Null
  }
  return $true
}

# ========== CLAUDE DEEP ==========
OC open 'https://claude.ai/new' | Out-Null; OCw 4
Cap4K 'claude-web' 'Claude Web' 'new-chat' '新对话' @('chat','centered-composer','sidebar') 'left sidebar + centered empty chat + bottom composer' 'New chat' @('open /new') 'Logged in after Google OAuth' $true

OC keys Escape | Out-Null; OCw 0.5
OC click --role button --name 'Hide sidebar' 2>$null | Out-Null; OCw 1.5
Cap4K 'claude-web' 'Claude Web' 'sidebar-collapsed' '侧栏收起' @('collapsed-rail','minimal') 'collapsed sidebar + main chat' 'Hide sidebar' @('click Hide sidebar') '' $true
OC click --role button --name 'Show sidebar' 2>$null | Out-Null; OCw 1
OC click --aria-label 'Show sidebar' 2>$null | Out-Null; OCw 1
# if still collapsed, open /new again
OC open 'https://claude.ai/new' | Out-Null; OCw 3

# Search
OC click --role button --name 'Search' 2>$null | Out-Null; OCw 1
OC keys 'Control+k' 2>$null | Out-Null; OCw 1.5
Cap4K 'claude-web' 'Claude Web' 'search' '搜索' @('command-palette','modal','search') 'search/command palette' 'Ctrl+K / Search' @('Ctrl+K or click Search') '' $true
OC keys Escape | Out-Null; OCw 1

# Projects
OC open 'https://claude.ai/projects' | Out-Null; OCw 4
Cap4K 'claude-web' 'Claude Web' 'projects' 'Projects' @('projects','grid','sidebar') 'projects list/grid' '/projects' @('open /projects') '' $true

# Artifacts
OC open 'https://claude.ai/artifacts' | Out-Null; OCw 4
Cap4K 'claude-web' 'Claude Web' 'artifacts' 'Artifacts' @('artifacts','gallery','sidebar') 'artifacts library' '/artifacts' @('open /artifacts') '' $true

# Recents / customize if reachable
OC open 'https://claude.ai/new' | Out-Null; OCw 3
OC click --text 'Customize' 2>$null | Out-Null; OCw 2
$u = OCurl
if ($u -match 'customize|settings|style') {
  Cap4K 'claude-web' 'Claude Web' 'customize' 'Customize' @('settings','customize') 'customize page' 'Customize' @('click Customize') "url=$u" $true
} else {
  Log "SKIP claude-web/customize reason=nav failed url=$u"
}
OC keys Escape | Out-Null

# Account / settings - try profile menu
OC open 'https://claude.ai/new' | Out-Null; OCw 3
OC click --text 'fanfan' 2>$null | Out-Null; OCw 1
OC find --text 'Settings' 2>$null | Out-Null
$st = (OC state | Out-String)
if ($st -match 'Settings' -or $st -match 'Account') {
  Cap4K 'claude-web' 'Claude Web' 'account-menu' '账户菜单' @('popover-menu','account') 'account popover' 'click profile' @('click fanfan/profile') '' $true
  OC click --text 'Settings' 2>$null | Out-Null; OCw 3
  Cap4K 'claude-web' 'Claude Web' 'settings' '设置' @('settings','modal-or-page') 'settings' 'Account > Settings' @('click Settings') (OCurl) $true
} else {
  # try settings URL
  OC open 'https://claude.ai/settings' | Out-Null; OCw 4
  $u = OCurl
  if ($u -match 'settings') {
    Cap4K 'claude-web' 'Claude Web' 'settings' '设置' @('settings') 'settings page' '/settings' @('open /settings') $u $true
  } else { Log "SKIP claude-web/settings reason=url=$u" }
}

# Settings subsections common
foreach ($pair in @(
  @('settings-profile','https://claude.ai/settings/profile','设置-个人资料'),
  @('settings-account','https://claude.ai/settings/account','设置-账户'),
  @('settings-privacy','https://claude.ai/settings/privacy','设置-隐私'),
  @('settings-billing','https://claude.ai/settings/billing','设置-账单'),
  @('settings-features','https://claude.ai/settings/features','设置-功能')
)) {
  OC open $pair[1] | Out-Null; OCw 3.5
  $u = OCurl
  if ($u -match 'login|signin|onboarding') { Log "SKIP claude-web/$($pair[0]) reason=auth url=$u"; continue }
  if ($u -notmatch 'settings') { Log "SKIP claude-web/$($pair[0]) reason=not settings url=$u"; continue }
  Cap4K 'claude-web' 'Claude Web' $pair[0] $pair[2] @('settings','section') 'settings section' $pair[1] @("open $($pair[1])") '' $true
}

# ========== PERPLEXITY GOOGLE ==========
OC open 'https://www.perplexity.ai/' | Out-Null; OCw 4
$u = OCurl
# if onboarding or need login, try Google
$need = ($u -match 'onboarding|login|signin') -or ((OC eval "(document.body.innerText||'').slice(0,300)"|Out-String) -match '(?i)sign in|log in|continue with google')
if ($need -or $true) {
  # try find Google button
  $found = (OC find --text 'Google' | Out-String)
  if ($found -match 'Continue with Google|Sign in with Google|Google') {
    Try-GoogleLogin 'perplexity' {
      OC click --role button --name 'Continue with Google' 2>$null | Out-Null
      OC click --text 'Continue with Google' 2>$null | Out-Null
      OC click --text 'Sign in with Google' 2>$null | Out-Null
    } | Out-Null
    OC open 'https://www.perplexity.ai/' | Out-Null; OCw 5
  } else {
    # open login page
    OC open 'https://www.perplexity.ai/onboarding' | Out-Null; OCw 3
    $found2 = (OC find --text 'Google' | Out-String)
    if ($found2 -match 'Google') {
      Try-GoogleLogin 'perplexity' {
        OC click --text 'Continue with Google' 2>$null | Out-Null
        OC click --text 'Sign in with Google' 2>$null | Out-Null
        OC click --role button --name 'Continue with Google' 2>$null | Out-Null
      } | Out-Null
      OC open 'https://www.perplexity.ai/' | Out-Null; OCw 5
    } else {
      Log 'SKIP perplexity google-login reason=no Google button found'
    }
  }
}
$u = OCurl
Cap4K 'perplexity-web' 'Perplexity' 'home' '首页/搜索' @('search-home','centered-composer') 'home search' $u @('open perplexity after login attempt') "post-google url=$u" ($u -notmatch 'login|signin')
OC open 'https://www.perplexity.ai/spaces' | Out-Null; OCw 4
$u=OCurl
if ($u -match 'login|signin') { Log "SKIP perplexity-web/spaces-v2 reason=$u" } else {
  Cap4K 'perplexity-web' 'Perplexity' 'spaces' 'Spaces' @('spaces') 'spaces' $u @('open /spaces') '' $true
}
OC open 'https://www.perplexity.ai/settings/account' | Out-Null; OCw 4
$u=OCurl
if ($u -match 'login|signin' -and $u -notmatch 'settings') { Log "SKIP perplexity settings reason=$u" } else {
  Cap4K 'perplexity-web' 'Perplexity' 'settings-account' '设置-账户' @('settings') 'settings' $u @('open settings') '' $true
}

# ========== LOVABLE GOOGLE ==========
OC open 'https://lovable.dev/login' | Out-Null; OCw 4
$found = (OC find --text 'Google' | Out-String)
if ($found -match 'Google') {
  Try-GoogleLogin 'lovable' {
    OC click --text 'Continue with Google' 2>$null | Out-Null
    OC click --text 'Sign in with Google' 2>$null | Out-Null
    OC click --role button --name 'Continue with Google' 2>$null | Out-Null
  } | Out-Null
  OC open 'https://lovable.dev/dashboard' | Out-Null; OCw 5
  $u=OCurl
  if ($u -match 'login|signin|signup') { Log "SKIP lovable-web/dashboard reason=still auth $u" }
  else { Cap4K 'lovable-web' 'Lovable' 'dashboard' '项目面板' @('dashboard','projects') 'dashboard' $u @('google login then /dashboard') '' $true }
} else {
  Log 'SKIP lovable google-login reason=no Google button'
  Cap4K 'lovable-web' 'Lovable' 'login' '登录页' @('login','auth-wall') 'login' (OCurl) @('open /login') 'no google btn visible or already captured home' $false
}

# Recapture lovable home if logged in later
OC open 'https://lovable.dev/' | Out-Null; OCw 4
Cap4K 'lovable-web' 'Lovable' 'home' '首页' @('home','app-or-marketing') 'home' (OCurl) @('open lovable.dev') '' $true

$log | Set-Content F:\project\design-library\_cap_log2.txt -Encoding UTF8
Write-Host '====LOG===='; $log; Write-Host 'DONE-DEEP'
