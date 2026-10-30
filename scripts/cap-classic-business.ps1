# cap-classic-business.ps1 — classic business UI capture (OpenCLI same-tab + physical 4K)
$ErrorActionPreference = 'Continue'
$env:Path = "F:\project\design-library\scripts;" + $env:Path
$env:NO_UPDATE_NOTIFIER = '1'
. F:\project\design-library\scripts\web-lib.ps1
$script:S = 'designlib'
function OC { & opencli browser $script:S @args 2>$null }
function OCg { & opencli browser gauth @args 2>$null }
function OCw([double]$s=2){ Start-Sleep -Milliseconds ([int]($s*1000)) }
function OCurl { ((OC eval 'location.href')|Out-String).Trim().Trim('"') }
function OCTitle {
  $t = (OC get title | Out-String)
  return ($t -split "`n" | Where-Object { $_.Trim() -and $_ -notmatch 'Update available|npm install|^\s*$' } | Select-Object -First 1)
}
function OCText([int]$n=1200) {
  ((OC eval "(document.body&&document.body.innerText||'').slice(0,$n)")|Out-String)
}
function Is-LoginWall {
  $u = OCurl; $t = OCTitle; $tx = OCText 600
  if ($u -match '(?i)login|signin|sign-in|signup|sign-up|/auth|/accounts\.google') { return $true }
  if ($t -match '(?i)^sign in|^log in|create account|sign up') { return $true }
  if ($tx -match '(?i)sign in with google|continue with google|log in to continue' -and $tx -match '(?i)password|email') { return $true }
  return $false
}
$log = New-Object System.Collections.Generic.List[string]
$skips = New-Object System.Collections.Generic.List[string]
function Log([string]$s){ $log.Add($s); Write-Host $s }
function Skip([string]$s){ $skips.Add($s); Log "SKIP $s" }

function Cap4K([string]$slug,[string]$app,[string]$screen,[string]$title,[string[]]$tags,[string]$layout,[string]$nav,[string[]]$clicks,[string]$notes,[bool]$loggedIn) {
  Chrome-ToPrimary; Focus-Chrome | Out-Null
  $url = OCurl
  $meta = @{
    app=$app; tier='classic'; tags=$tags; layout=$layout; nav=$nav
    source='User Chrome fanfan OpenCLI+physical 4K'
    clicks=$clicks; notes=$notes
    privacy='May show account/UI; redact before external share.'
    url=$url
  }
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

function Try-GoogleLogin([string]$label) {
  Log "GOOGLE-LOGIN start $label"
  # Prefer clicking Continue/Sign in with Google on current page
  $clicked = $false
  foreach ($name in @('Continue with Google','Sign in with Google','Log in with Google','Google','使用 Google 账号','使用 Google 登录')) {
    $r = (OC click --role button --name $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { $clicked = $true; break }
    $r = (OC click --text $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { $clicked = $true; break }
  }
  if (-not $clicked) {
    # try link role
    foreach ($name in @('Continue with Google','Sign in with Google')) {
      $r = (OC click --role link --name $name 2>&1 | Out-String)
      if ($r -match '"clicked":\s*true') { $clicked = $true; break }
    }
  }
  if (-not $clicked) {
    Skip "google-login $label reason=no Google button"
    return $false
  }
  OCw 3
  $ok = Focus-Title 'Google accounts'
  if (-not $ok) { $ok = Focus-Title 'Sign in' }
  if (-not $ok) { Skip "google-login $label reason=no Google accounts popup"; return $false }
  opencli browser gauth unbind 2>$null | Out-Null
  opencli browser gauth bind 2>$null | Out-Null
  OCw 1
  $gu = ((OCg eval 'location.href')|Out-String)
  if ($gu -notmatch 'accounts.google.com') {
    Skip "google-login $label reason=bind not accounts.google.com ($gu)"
    return $false
  }
  $st = (OCg state | Out-String)
  if ($st -match 'Choose an account' -or $st -match 'fanfan') {
    OCg click --text 'fanfan' 2>$null | Out-Null
    OCw 1
    OCg eval "const el=[...document.querySelectorAll('div[role=link],li div')].find(e=>/fanfan|qwe1174740998/i.test(e.innerText||'')); if(el){el.click();'ok'} else 'none'" 2>$null | Out-Null
    OCw 3
  }
  for ($i=0;$i -lt 3;$i++) {
    $r = (OCg click --role button --name 'Continue' 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { OCw 4; break }
    $r = (OCg click --role button --name 'Allow' 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { OCw 4; break }
    OCw 1
  }
  Log "GOOGLE-LOGIN done $label"
  Focus-Title 'Chrome' | Out-Null
  # rebind designlib to foreground tab
  opencli browser designlib unbind 2>$null | Out-Null
  opencli browser designlib bind 2>$null | Out-Null
  OCw 2
  return $true
}

function Ensure-Bound {
  opencli browser designlib unbind 2>$null | Out-Null
  opencli browser designlib bind 2>$null | Out-Null
  OCw 0.5
}

function Open-Once([string]$url, [int]$wait=5) {
  OC open $url | Out-Null
  OCw $wait
  Ensure-Bound
}

function Click-Try([string[]]$names, [string]$role='') {
  foreach ($name in $names) {
    if ($role) {
      $r = (OC click --role $role --name $name 2>&1 | Out-String)
      if ($r -match '"clicked":\s*true') { return $name }
    }
    $r = (OC click --name $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { return $name }
    $r = (OC click --text $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { return $name }
  }
  return $null
}

# ========== 5. MARKETING (no login) ==========
Log '==== MARKETING ===='
Open-Once 'https://stripe.com' 5
Cap4K 'stripe-web' 'Stripe Marketing' 'home' '官网首页' @('marketing','hero','forms') 'marketing hero + product nav' 'stripe.com' @('open stripe.com') 'Landing page' $false
$c = Click-Try @('Products','产品') 'link'
if ($c) { OCw 2; Cap4K 'stripe-web' 'Stripe Marketing' 'products' '产品导航' @('marketing','nav','mega-menu') 'products menu or page' $c @("click $c") '' $false; OC keys Escape | Out-Null; OCw 0.5 }
# product page
$c = Click-Try @('Payments','支付') 'link'
if ($c) {
  OCw 3
  Cap4K 'stripe-web' 'Stripe Marketing' 'payments' 'Payments 产品页' @('marketing','product-page','forms') 'product marketing page' (OCurl) @("click $c") '' $false
} else {
  # navigate via path without new product open - still same tab OC open is OK once for sibling marketing
  Open-Once 'https://stripe.com/payments' 4
  Cap4K 'stripe-web' 'Stripe Marketing' 'payments' 'Payments 产品页' @('marketing','product-page','forms') 'product marketing page' 'stripe.com/payments' @('open /payments') '' $false
}

Open-Once 'https://www.apple.com' 5
Cap4K 'apple-web' 'Apple' 'home' '官网首页' @('marketing','hero','apple') 'apple.com home' 'apple.com' @('open apple.com') '' $false
$c = Click-Try @('iPhone','Mac','Watch') 'link'
if ($c) {
  OCw 4
  Cap4K 'apple-web' 'Apple' 'product' "产品页-$c" @('marketing','product-page','apple') 'apple product page' (OCurl) @("click $c") '' $false
} else {
  Open-Once 'https://www.apple.com/iphone/' 4
  Cap4K 'apple-web' 'Apple' 'product' 'iPhone 产品页' @('marketing','product-page','apple') 'iphone product page' 'apple.com/iphone' @('open /iphone') '' $false
}

# ========== 1. FORMS: Stripe dashboard + Linear ==========
Log '==== FORMS stripe-dashboard + linear ===='
Open-Once 'https://dashboard.stripe.com' 6
if (Is-LoginWall) {
  Cap4K 'stripe-dashboard' 'Stripe Dashboard' 'login' '登录墙' @('forms','login','auth-wall') 'dashboard login' (OCurl) @('open dashboard.stripe.com') 'Login required' $false
  $ok = Try-GoogleLogin 'stripe-dashboard'
  if ($ok -and -not (Is-LoginWall)) {
    Cap4K 'stripe-dashboard' 'Stripe Dashboard' 'home' 'Dashboard 主壳' @('forms','admin','dashboard') 'stripe dashboard shell' (OCurl) @('Google login') '' $true
    $c = Click-Try @('Settings','设置') 
    if ($c) { OCw 3; Cap4K 'stripe-dashboard' 'Stripe Dashboard' 'settings' '设置' @('forms','settings') 'settings' (OCurl) @("click $c") '' $true }
  } else {
    Skip 'stripe-dashboard/deep reason=login wall after Google attempt'
  }
} else {
  Cap4K 'stripe-dashboard' 'Stripe Dashboard' 'home' 'Dashboard 主壳' @('forms','admin','dashboard') 'stripe dashboard shell' (OCurl) @('open dashboard') '' $true
  $c = Click-Try @('Settings','设置','Payments','支付')
  if ($c) { OCw 3; Cap4K 'stripe-dashboard' 'Stripe Dashboard' 'section' "分区-$c" @('forms','admin') 'dashboard section' (OCurl) @("click $c") '' $true }
}

Open-Once 'https://linear.app' 5
# may land marketing or app
$u = OCurl
if ($u -match 'linear.app/login' -or (Is-LoginWall)) {
  Cap4K 'linear-web' 'Linear' 'login' '登录墙' @('forms','login','auth-wall') 'linear login' (OCurl) @('open linear.app') '' $false
  $ok = Try-GoogleLogin 'linear'
  OCw 3
}
# try app
if ((OCurl) -match 'linear.app' -and -not (Is-LoginWall)) {
  Cap4K 'linear-web' 'Linear' 'home' '主壳/列表' @('forms','admin','list') 'linear app or marketing logged' (OCurl) @('after open/login') '' (-not (Is-LoginWall))
  $c = Click-Try @('Settings','设置','Inbox','Issues')
  if ($c) {
    OCw 3
    Cap4K 'linear-web' 'Linear' 'section' "分区-$c" @('forms','settings','list') 'linear section' (OCurl) @("click $c") '' $true
  }
} else {
  # capture marketing home as fallback
  Open-Once 'https://linear.app' 4
  Cap4K 'linear-web' 'Linear' 'marketing-home' '营销首页' @('marketing','forms') 'linear marketing' 'linear.app' @('open linear.app') 'Could not enter app' $false
  Skip 'linear-web/app reason=login wall'
}

# ========== 2. ADMIN: Shopify + GitHub ==========
Log '==== ADMIN shopify + github ===='
Open-Once 'https://admin.shopify.com' 6
if (Is-LoginWall) {
  Cap4K 'shopify-admin' 'Shopify Admin' 'login' '登录墙' @('admin','login','auth-wall') 'shopify admin login' (OCurl) @('open admin.shopify.com') '' $false
  $ok = Try-GoogleLogin 'shopify-admin'
  if ($ok -and -not (Is-LoginWall)) {
    Cap4K 'shopify-admin' 'Shopify Admin' 'home' 'Admin 主壳' @('admin','dashboard') 'shopify admin' (OCurl) @('Google login') '' $true
  } else {
    Skip 'shopify-admin/deep reason=login wall'
  }
} else {
  Cap4K 'shopify-admin' 'Shopify Admin' 'home' 'Admin 主壳' @('admin','dashboard') 'shopify admin' (OCurl) @('open admin') '' $true
  $c = Click-Try @('Products','Orders','Settings','产品','订单','设置')
  if ($c) { OCw 3; Cap4K 'shopify-admin' 'Shopify Admin' 'section' "分区-$c" @('admin','list') 'admin section' (OCurl) @("click $c") '' $true }
}

Open-Once 'https://github.com' 5
Cap4K 'github-web' 'GitHub' 'home' '首页/仪表' @('admin','list','collab') 'github home/dashboard' (OCurl) @('open github.com') '' (-not (Is-LoginWall))
# Issues via click if possible
$c = Click-Try @('Issues','Pull requests','Pull requests')
if ($c) {
  OCw 3
  Cap4K 'github-web' 'GitHub' 'issues' 'Issues/PR' @('admin','list','form') 'issues list' (OCurl) @("click $c") '' $true
} else {
  # try going to notifications or settings via nav
  $c = Click-Try @('Settings')
  if ($c) {
    OCw 3
    Cap4K 'github-web' 'GitHub' 'settings' '设置' @('admin','forms','settings') 'settings' (OCurl) @("click $c") '' $true
  } else {
    # same-tab navigate once for issues explore
    OC eval "location.href='https://github.com/issues'" | Out-Null; OCw 4
    if (-not (Is-LoginWall)) {
      Cap4K 'github-web' 'GitHub' 'issues' 'Issues' @('admin','list') 'github issues' (OCurl) @('location issues') '' $true
    } else { Skip 'github-web/issues reason=login' }
  }
}
# settings profile via same-tab hash/path
OC eval "location.href='https://github.com/settings/profile'" | Out-Null; OCw 4
if (-not (Is-LoginWall) -and (OCurl) -match 'settings') {
  Cap4K 'github-web' 'GitHub' 'settings-profile' 'Settings Profile' @('admin','forms','settings') 'profile settings form' (OCurl) @('location settings/profile') 'Privacy: account fields; redact before share' $true
} else {
  Skip 'github-web/settings-profile reason=login or redirect'
}

# ========== 3. COLLAB: Slack + Notion ==========
Log '==== COLLAB slack + notion ===='
Open-Once 'https://app.slack.com' 6
if (Is-LoginWall) {
  Cap4K 'slack-web' 'Slack' 'login' '登录墙' @('collab','login','auth-wall') 'slack login' (OCurl) @('open app.slack.com') '' $false
  $ok = Try-GoogleLogin 'slack'
  if ($ok -and -not (Is-LoginWall)) {
    Cap4K 'slack-web' 'Slack' 'home' '工作区主壳' @('collab','chat','sidebar') 'slack workspace' (OCurl) @('Google login') '' $true
  } else { Skip 'slack-web/deep reason=login wall' }
} else {
  Cap4K 'slack-web' 'Slack' 'home' '工作区主壳' @('collab','chat','sidebar') 'slack workspace' (OCurl) @('open app.slack.com') '' $true
  $c = Click-Try @('Preferences','Preferences','设置','Apps')
  if ($c) { OCw 3; Cap4K 'slack-web' 'Slack' 'prefs' "偏好-$c" @('collab','settings') 'prefs' (OCurl) @("click $c") '' $true; OC keys Escape | Out-Null }
}

Open-Once 'https://www.notion.so' 6
if (Is-LoginWall) {
  Cap4K 'notion-web' 'Notion' 'login' '登录墙' @('collab','login','auth-wall') 'notion login' (OCurl) @('open notion.so') '' $false
  $ok = Try-GoogleLogin 'notion'
  OCw 4
}
if (-not (Is-LoginWall)) {
  Cap4K 'notion-web' 'Notion' 'home' '工作区/主页' @('collab','docs','sidebar') 'notion workspace' (OCurl) @('after open/login') '' $true
  $c = Click-Try @('Settings','Settings & members','设置','设置与成员')
  if ($c) {
    OCw 3
    Cap4K 'notion-web' 'Notion' 'settings' '设置' @('collab','forms','settings') 'settings modal/page' (OCurl) @("click $c") '' $true
    OC keys Escape | Out-Null
  }
} else {
  Skip 'notion-web/deep reason=login wall'
}

# ========== 4. FILES: Drive + Figma ==========
Log '==== FILES drive + figma ===='
Open-Once 'https://drive.google.com' 6
if (Is-LoginWall) {
  Cap4K 'google-drive' 'Google Drive' 'login' '登录墙' @('files','login') 'drive login' (OCurl) @('open drive') '' $false
  Skip 'google-drive/deep reason=login wall (use Google session)'
} else {
  Cap4K 'google-drive' 'Google Drive' 'home' '我的云端硬盘' @('files','list','grid') 'drive file browser' (OCurl) @('open drive.google.com') '' $true
  $c = Click-Try @('Shared with me','与我共享','Recent','最近')
  if ($c) { OCw 3; Cap4K 'google-drive' 'Google Drive' 'section' "分区-$c" @('files','list') 'drive section' (OCurl) @("click $c") '' $true }
  $c = Click-Try @('Settings','设置')
  if ($c) { OCw 2; Cap4K 'google-drive' 'Google Drive' 'settings' '设置' @('files','settings','forms') 'settings' (OCurl) @("click $c") '' $true; OC keys Escape | Out-Null }
}

Open-Once 'https://www.figma.com' 5
if (Is-LoginWall -or (OCurl) -match 'login') {
  Cap4K 'figma-web' 'Figma' 'login' '登录墙' @('files','login','auth-wall') 'figma login' (OCurl) @('open figma.com') '' $false
  $ok = Try-GoogleLogin 'figma'
  OCw 4
}
if (-not (Is-LoginWall)) {
  Cap4K 'figma-web' 'Figma' 'files' '文件浏览器' @('files','grid','collab') 'figma file browser' (OCurl) @('after open/login') '' $true
  $c = Click-Try @('Recents','Recent','Drafts','Community')
  if ($c) { OCw 3; Cap4K 'figma-web' 'Figma' 'section' "分区-$c" @('files','grid') 'figma section' (OCurl) @("click $c") '' $true }
} else {
  # marketing fallback
  Open-Once 'https://www.figma.com' 4
  Cap4K 'figma-web' 'Figma' 'marketing' '营销首页' @('marketing','files') 'figma marketing' 'figma.com' @('open figma.com') 'login blocked deeper' $false
  Skip 'figma-web/files reason=login wall'
}

# ========== 6. DENSE: TradingView + AWS ==========
Log '==== DENSE tradingview + aws ===='
Open-Once 'https://www.tradingview.com/chart/' 6
Cap4K 'tradingview-web' 'TradingView' 'chart' '图表主壳' @('dense','chart','pro') 'trading chart workspace' (OCurl) @('open /chart/') 'High density; may show symbols' (-not (Is-LoginWall))
$c = Click-Try @('Watchlist','Screeners','日历','Watchlist')
if ($c) { OCw 2; Cap4K 'tradingview-web' 'TradingView' 'panel' "面板-$c" @('dense','panel') 'side panel' (OCurl) @("click $c") '' $true }

Open-Once 'https://console.aws.amazon.com' 6
if (Is-LoginWall) {
  Cap4K 'aws-console' 'AWS Console' 'login' '登录墙' @('dense','login','auth-wall') 'aws console login' (OCurl) @('open console.aws.amazon.com') 'Deep pages SKIP without login' $false
  Skip 'aws-console/deep reason=login wall'
} else {
  Cap4K 'aws-console' 'AWS Console' 'home' '控制台主页' @('dense','admin','console') 'aws console home' (OCurl) @('open console') '' $true
  $c = Click-Try @('Services','服务','All services')
  if ($c) { OCw 2; Cap4K 'aws-console' 'AWS Console' 'services' '服务目录' @('dense','nav') 'services menu' (OCurl) @("click $c") '' $true; OC keys Escape | Out-Null }
}

$log | Set-Content 'F:\project\design-library\_cap_log_classic.txt' -Encoding UTF8
$skips | Set-Content 'F:\project\design-library\_cap_skips_classic.txt' -Encoding UTF8
Write-Host '==== SKIPS ===='; $skips
Write-Host 'DONE-CLASSIC'
