# cap-classic-business.ps1 — classic business UI via OpenCLI page screenshot (NOT fullscreen)
# NEVER use Save-Shot / Capture-Fullscreen / CopyFromScreen — LoL overlays break those.
$ErrorActionPreference = 'Continue'
$env:Path = "F:\project\design-library\scripts;" + $env:Path
$env:NO_UPDATE_NOTIFIER = '1'
$script:S = 'designlib'
. F:\project\design-library\scripts\opencli-lib.ps1
$script:S = 'designlib'
Add-Type -AssemblyName System.Drawing

function OC { & opencli browser --session $script:S @args 2>$null }
function OCg { & opencli browser --session gauth @args 2>$null }
function OCw([double]$s=2){ Start-Sleep -Milliseconds ([int]($s*1000)) }
function OCurl { ((OC eval 'location.href')|Out-String).Trim().Trim('"') }
function OCTitle {
  $t = (OC get title | Out-String)
  return ($t -split "`n" | Where-Object { $_.Trim() -and $_ -notmatch 'Update available|npm install|^\s*$' } | Select-Object -First 1)
}
function OCText([int]$n=1600) {
  ((OC eval "(document.body&&document.body.innerText||'').slice(0,$n)")|Out-String)
}
function Is-LoginWall {
  $u = OCurl; $t = OCTitle; $tx = OCText 800
  if ($u -match '(?i)login|signin|sign-in|signup|sign-up|/auth|accounts\.google|signin\.aws') { return $true }
  if ($t -match '(?i)^sign in|^log in|create account|sign up|Amazon Web Services Sign-In') { return $true }
  if ($tx -match '(?i)sign in with google|continue with google|log in to continue|Enter your email' -and $tx -match '(?i)password|email|Google') { return $true }
  return $false
}
$log = New-Object System.Collections.Generic.List[string]
$skips = New-Object System.Collections.Generic.List[string]
$pageNotes = @{}
function Log([string]$s){ $log.Add($s); Write-Host $s }
function Skip([string]$s){ $skips.Add($s); Log "SKIP $s" }

function CapOC {
  param(
    [string]$slug,[string]$app,[string]$screen,[string]$title,[string[]]$tags,
    [string]$layout,[string]$nav,[string[]]$clicks,[string]$notes,[bool]$loggedIn,
    [switch]$Full,[int]$W=1792,[int]$H=1024
  )
  $dir = Join-Path $script:Root "apps\$slug\$screen"
  if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
  New-Item -ItemType Directory -Force $dir | Out-Null
  $png = Join-Path $dir 'shot.png'; $jpg = Join-Path $dir 'shot-ai.jpg'
  if ($Full) { OC screenshot $png --full-page | Out-Null } else { OC screenshot $png --width $W --height $H | Out-Null }
  if (-not (Test-Path $png)) { Log "FAIL $slug/$screen (no png)"; return }
  $img = [Drawing.Image]::FromFile($png); $w = $img.Width; $h = $img.Height
  # reject obvious tiny/empty failures
  if ($w -lt 200 -or $h -lt 200) { $img.Dispose(); Log "FAIL $slug/$screen tiny ${w}x$h"; return }
  $tw = [Math]::Min(1920, $w); $th = [int]($h * $tw / $w)
  $bmp = New-Object Drawing.Bitmap $tw, $th; $g = [Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($img, 0, 0, $tw, $th); $g.Dispose(); $img.Dispose()
  $enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
  $ep = New-Object Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = [Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality, [long]82)
  $bmp.Save($jpg, $enc, $ep); $bmp.Dispose()
  $url = OCurl
  $tx = (OCText 900) -replace '\s+',' '
  $mode = if ($Full) { 'opencli-fullpage' } else { "opencli-viewport-${W}x$H" }
  $meta = [ordered]@{
    app=$app; screen=$screen; title=$title; tier='classic'; style_tags=$tags
    layout=$layout; nav=$nav; platform='web'
    source='User Chrome on fanfan via OpenCLI browser screenshot (page viewport, NOT fullscreen)'
    tool='opencli'; clicks=$clicks; notes=$notes
    privacy='May show account/UI; redact before external share.'
    captured_at=(Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    capture_mode=$mode
    resolution_note='OpenCLI CDP page screenshot; independent of desktop overlay (LoL/Win+P). Viewport CSS override when not full-page.'
    full_px="${w}x$h"; ai_px="${tw}x$th"
    shot_full='shot.png'; shot_ai='shot-ai.jpg'
    bytes=@{ full=(Get-Item $png).Length; ai=(Get-Item $jpg).Length }
    url=$url; logged_in=$loggedIn; machine='fanfan'; style_doc='STYLE-GUIDE.md'
    page_text_snip=($tx.Substring(0, [Math]::Min(500, $tx.Length)))
  }
  [IO.File]::WriteAllText((Join-Path $dir 'meta.json'), ($meta | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
  if (-not $pageNotes.ContainsKey($slug)) { $pageNotes[$slug] = New-Object System.Collections.Generic.List[string] }
  $pageNotes[$slug].Add("## $screen — $title`n- URL: $url`n- Layout note: $layout`n- Text snip: $tx`n")
  Log "CAP $slug/$screen :: ${w}x$h mode=$mode url=$url"
}

function Ensure-Bound {
  opencli browser unbind --session designlib 2>$null | Out-Null
  opencli browser bind --session designlib 2>$null | Out-Null
  OCw 0.6
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
  Start-Sleep 1
  [void][WinFocus3]::SetForegroundWindow($h)
  return $true
}
function Try-GoogleLogin([string]$label) {
  Log "GOOGLE-LOGIN start $label"
  $clicked = $false
  foreach ($name in @('Continue with Google','Sign in with Google','Log in with Google','Google','使用 Google 账号','使用 Google 登录')) {
    $r = (OC click --role button --name $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { $clicked = $true; break }
    $r = (OC click --text $name 2>&1 | Out-String)
    if ($r -match '"clicked":\s*true') { $clicked = $true; break }
  }
  if (-not $clicked) {
    foreach ($name in @('Continue with Google','Sign in with Google')) {
      $r = (OC click --role link --name $name 2>&1 | Out-String)
      if ($r -match '"clicked":\s*true') { $clicked = $true; break }
    }
  }
  if (-not $clicked) { Skip "google-login $label reason=no Google button"; return $false }
  OCw 3
  $ok = Focus-Title 'Google accounts'
  if (-not $ok) { $ok = Focus-Title 'Sign in' }
  if (-not $ok) { Skip "google-login $label reason=no Google accounts popup"; return $false }
  opencli browser unbind --session gauth 2>$null | Out-Null
  opencli browser bind --session gauth 2>$null | Out-Null
  OCw 1
  $gu = ((OCg eval 'location.href')|Out-String)
  if ($gu -notmatch 'accounts.google.com') {
    Skip "google-login $label reason=bind not accounts.google.com ($gu)"; return $false
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
  Ensure-Bound
  OCw 2
  return $true
}

function Write-StyleGuide([string]$slug,[string]$appName,[string]$dna,[string[]]$sections) {
  $dir = Join-Path $script:Root "apps\$slug"
  if (-not (Test-Path $dir)) { return }
  $screens = Get-ChildItem $dir -Directory | ForEach-Object Name
  if (-not $screens) { return }
  $body = @"
# $appName — 风格总指南（STYLE-GUIDE）

> 用途：还原 $appName 经典业务 UI；素材来自 OpenCLI 页面截图（非全屏）。  
> 平台：Web · capture_mode=opencli-viewport/fullpage。  
> 截图：``apps/$slug/<screen>/``。

---

## 一、产品整体 DNA

$dna

---

## 二、分页面说明

$(($sections -join "`n`n"))

---

## 三、采集备注
- 禁止用整屏物理截图；本批均为浏览器页面截图。
- 登录墙深页已 SKIP，仅保留可公开或本机会话可达页。
"@
  [IO.File]::WriteAllText((Join-Path $dir 'STYLE-GUIDE.md'), $body, (New-Object Text.UTF8Encoding $false))
  Log "STYLE $slug"
}

# ========== MARKETING ==========
Log '==== MARKETING stripe + apple ===='
Open-Once 'https://stripe.com' 5
CapOC 'stripe-web' 'Stripe Marketing' 'home' '官网首页' @('marketing','hero','forms') 'marketing hero + product nav' 'stripe.com' @('open stripe.com') 'Landing page' $false -Full
$c = Click-Try @('Products','产品') 'link'
if ($c) { OCw 2; CapOC 'stripe-web' 'Stripe Marketing' 'products' '产品导航' @('marketing','nav','mega-menu') 'products menu or page' $c @("click $c") '' $false; OC keys Escape | Out-Null; OCw 0.5 }
Open-Once 'https://stripe.com/payments' 4
CapOC 'stripe-web' 'Stripe Marketing' 'payments' 'Payments 产品页' @('marketing','product-page','forms') 'product marketing page' 'stripe.com/payments' @('open /payments') '' $false -Full

Open-Once 'https://checkout.stripe.dev/' 5
CapOC 'stripe-dashboard' 'Stripe Dashboard' 'checkout-demo' 'Checkout 公开示意' @('forms','checkout','demo') 'checkout.stripe.dev demo' 'checkout.stripe.dev' @('open checkout.stripe.dev') 'Public demo; not private dashboard' $false

Open-Once 'https://dashboard.stripe.com' 6
if (Is-LoginWall) {
  CapOC 'stripe-dashboard' 'Stripe Dashboard' 'login' '登录墙' @('forms','login','auth-wall') 'dashboard login' (OCurl) @('open dashboard.stripe.com') 'Login required' $false
  Skip 'stripe-dashboard/deep reason=login wall'
} else {
  CapOC 'stripe-dashboard' 'Stripe Dashboard' 'home' 'Dashboard 主壳' @('forms','admin','dashboard') 'stripe dashboard shell' (OCurl) @('open dashboard') '' $true
}

Open-Once 'https://www.apple.com' 5
CapOC 'apple-web' 'Apple' 'home' '官网首页' @('marketing','hero','apple') 'apple.com home' 'apple.com' @('open apple.com') '' $false -Full
Open-Once 'https://www.apple.com/iphone/' 5
CapOC 'apple-web' 'Apple' 'product' 'iPhone 产品页' @('marketing','product-page','apple') 'iphone product page' 'apple.com/iphone' @('open /iphone') '' $false -Full

# ========== FORMS: Linear ==========
Log '==== FORMS linear ===='
Open-Once 'https://linear.app' 5
CapOC 'linear-web' 'Linear' 'home' '营销首页' @('forms','marketing','product') 'linear marketing home' 'linear.app' @('open linear.app') '' $false -Full
$c = Click-Try @('Pricing','定价') 'link'
if ($c) {
  OCw 4
  CapOC 'linear-web' 'Linear' 'pricing' '定价页' @('forms','pricing','marketing') 'pricing page' (OCurl) @("click $c") '' $false -Full
} else {
  Open-Once 'https://linear.app/pricing' 4
  CapOC 'linear-web' 'Linear' 'pricing' '定价页' @('forms','pricing','marketing') 'pricing page' 'linear.app/pricing' @('open /pricing') '' $false -Full
}
Open-Once 'https://linear.app/login' 4
if (Is-LoginWall -or (OCurl) -match 'login') {
  CapOC 'linear-web' 'Linear' 'login' '登录墙' @('forms','login','auth-wall') 'linear login' (OCurl) @('open /login') 'App deep SKIP' $false
  Skip 'linear-web/app reason=login wall'
}

# ========== ADMIN: Shopify + GitHub ==========
Log '==== ADMIN shopify + github ===='
Open-Once 'https://admin.shopify.com' 6
if (Is-LoginWall) {
  CapOC 'shopify-admin' 'Shopify Admin' 'login' '登录墙' @('admin','login','auth-wall') 'shopify admin login' (OCurl) @('open admin.shopify.com') 'Deep SKIP' $false
  Skip 'shopify-admin/deep reason=login wall'
} else {
  CapOC 'shopify-admin' 'Shopify Admin' 'home' 'Admin 主壳' @('admin','dashboard') 'shopify admin' (OCurl) @('open admin') '' $true
}

Open-Once 'https://github.com' 5
$ghLogged = -not (Is-LoginWall)
CapOC 'github-web' 'GitHub' 'home' '首页/仪表' @('admin','list','collab') 'github home/dashboard' (OCurl) @('open github.com') '' $ghLogged
OC eval "location.href='https://github.com/issues'" | Out-Null; OCw 4
if (-not (Is-LoginWall)) {
  CapOC 'github-web' 'GitHub' 'issues' 'Issues' @('admin','list') 'github issues' (OCurl) @('location issues') '' $true
} else { Skip 'github-web/issues reason=login' }
OC eval "location.href='https://github.com/settings/profile'" | Out-Null; OCw 4
if (-not (Is-LoginWall) -and (OCurl) -match 'settings') {
  CapOC 'github-web' 'GitHub' 'settings-profile' 'Settings Profile' @('admin','forms','settings') 'profile settings form' (OCurl) @('location settings/profile') 'Privacy: account fields; redact before share' $true
} else {
  Skip 'github-web/settings-profile reason=login or redirect'
}

# ========== COLLAB: Slack + Notion ==========
Log '==== COLLAB slack + notion ===='
Open-Once 'https://slack.com' 5
CapOC 'slack-web' 'Slack' 'marketing' '营销首页' @('collab','marketing') 'slack.com marketing' 'slack.com' @('open slack.com') '' $false -Full
Open-Once 'https://slack.com/signin' 5
CapOC 'slack-web' 'Slack' 'login' '登录墙' @('collab','login','auth-wall') 'slack signin' (OCurl) @('open slack.com/signin') '' $false
Open-Once 'https://app.slack.com' 5
if (Is-LoginWall) {
  Skip 'slack-web/workspace reason=login wall'
} else {
  CapOC 'slack-web' 'Slack' 'home' '工作区主壳' @('collab','chat','sidebar') 'slack workspace' (OCurl) @('open app.slack.com') '' $true
}

Open-Once 'https://www.notion.so' 6
if (Is-LoginWall) {
  CapOC 'notion-web' 'Notion' 'login' '登录墙' @('collab','login','auth-wall') 'notion login' (OCurl) @('open notion.so') '' $false
  $ok = Try-GoogleLogin 'notion'
  OCw 4
}
if (-not (Is-LoginWall)) {
  CapOC 'notion-web' 'Notion' 'home' '工作区/主页' @('collab','docs','sidebar') 'notion workspace' (OCurl) @('after open/login') '' $true
  $c = Click-Try @('Settings','Settings & members','设置','设置与成员')
  if ($c) {
    OCw 3
    CapOC 'notion-web' 'Notion' 'settings' '设置' @('collab','forms','settings') 'settings modal/page' (OCurl) @("click $c") '' $true
    OC keys Escape | Out-Null
  }
} else {
  # marketing fallback
  Open-Once 'https://www.notion.com' 4
  CapOC 'notion-web' 'Notion' 'marketing' '营销首页' @('collab','marketing') 'notion marketing' (OCurl) @('open notion.com') 'login blocked deeper' $false -Full
  Skip 'notion-web/deep reason=login wall'
}

# ========== FILES: Drive + Figma ==========
Log '==== FILES drive + figma ===='
Open-Once 'https://drive.google.com' 6
if (Is-LoginWall) {
  CapOC 'google-drive' 'Google Drive' 'login' '登录墙' @('files','login') 'drive login' (OCurl) @('open drive') '' $false
  Skip 'google-drive/deep reason=login wall'
} else {
  CapOC 'google-drive' 'Google Drive' 'home' '我的云端硬盘' @('files','list','grid') 'drive file browser' (OCurl) @('open drive.google.com') '' $true
  $c = Click-Try @('Shared with me','与我共享','Recent','最近')
  if ($c) { OCw 3; CapOC 'google-drive' 'Google Drive' 'section' "分区-$c" @('files','list') 'drive section' (OCurl) @("click $c") '' $true }
  $c = Click-Try @('Settings','设置')
  if ($c) { OCw 2; CapOC 'google-drive' 'Google Drive' 'settings' '设置' @('files','settings','forms') 'settings' (OCurl) @("click $c") '' $true; OC keys Escape | Out-Null }
}

Open-Once 'https://www.figma.com' 5
if (Is-LoginWall -or (OCurl) -match 'login') {
  CapOC 'figma-web' 'Figma' 'login' '登录墙' @('files','login','auth-wall') 'figma login' (OCurl) @('open figma.com') '' $false
  $ok = Try-GoogleLogin 'figma'
  OCw 4
}
if (-not (Is-LoginWall) -and (OCurl) -notmatch 'login') {
  CapOC 'figma-web' 'Figma' 'files' '文件浏览器' @('files','grid','collab') 'figma file browser' (OCurl) @('after open/login') '' $true
  $c = Click-Try @('Recents','Recent','Drafts','Community')
  if ($c) { OCw 3; CapOC 'figma-web' 'Figma' 'section' "分区-$c" @('files','grid') 'figma section' (OCurl) @("click $c") '' $true }
} else {
  Open-Once 'https://www.figma.com' 4
  CapOC 'figma-web' 'Figma' 'marketing' '营销首页' @('marketing','files') 'figma marketing' 'figma.com' @('open figma.com') 'login blocked deeper' $false -Full
  Skip 'figma-web/files reason=login wall'
}

# ========== DENSE: TradingView + AWS ==========
Log '==== DENSE tradingview + aws ===='
Open-Once 'https://www.tradingview.com/chart/' 6
CapOC 'tradingview-web' 'TradingView' 'chart' '图表主壳' @('dense','chart','pro') 'trading chart workspace' (OCurl) @('open /chart/') 'High density; may show symbols' (-not (Is-LoginWall))
$c = Click-Try @('Watchlist','Screeners','日历','Watchlist')
if ($c) { OCw 2; CapOC 'tradingview-web' 'TradingView' 'panel' "面板-$c" @('dense','panel') 'side panel' (OCurl) @("click $c") '' $true }
else {
  # try opening right panel via UI button common labels
  $c = Click-Try @('Object tree','Alerts','News')
  if ($c) { OCw 2; CapOC 'tradingview-web' 'TradingView' 'panel' "面板-$c" @('dense','panel') 'side panel' (OCurl) @("click $c") '' $true }
}

Open-Once 'https://console.aws.amazon.com' 6
if (Is-LoginWall) {
  CapOC 'aws-console' 'AWS Console' 'login' '登录墙' @('dense','login','auth-wall') 'aws console login' (OCurl) @('open console.aws.amazon.com') 'Deep pages SKIP without login' $false
  Skip 'aws-console/deep reason=login wall'
} else {
  CapOC 'aws-console' 'AWS Console' 'home' '控制台主页' @('dense','admin','console') 'aws console home' (OCurl) @('open console') '' $true
}

# ========== STYLE GUIDES from real page notes ==========
function NotesFor($slug) {
  if ($pageNotes.ContainsKey($slug)) { return ($pageNotes[$slug] -join "`n") }
  return '(no page notes)'
}
Write-StyleGuide 'stripe-web' 'Stripe Marketing' @"
### 一句话定位
**深色/高对比营销站 + 大号产品叙事 + 清晰产品导航**；支付基础设施的品牌门面。

### 色板与字体（观察）
- 背景偏黑/深灰，强调色为 Stripe 紫/亮强调；大标题极粗。
- 无衬线；英雄句超大；次级说明偏 muted。

### 组件通则
- 顶栏产品/解决方案/开发者/资源；CTA「Start now / Contact sales」。
- 产品页长滚动，图文分栏、特性卡片。
"@ @(NotesFor 'stripe-web')

Write-StyleGuide 'stripe-dashboard' 'Stripe Dashboard' @"
### 一句话定位
**Dashboard 为表单/经营后台；公开 checkout.stripe.dev 为结账示意**。登录墙与示意页分开存档。

### 设计原则
1. 登录墙：居中品牌 + 邮箱/SSO。
2. Checkout demo：左预览/右配置或全页结账示意，强调「No code / Low code」。
"@ @(NotesFor 'stripe-dashboard')

Write-StyleGuide 'linear-web' 'Linear' @"
### 一句话定位
**极简深色产品营销 + 清晰定价卡**；Issue tracker 气质克制、工程向。

### 色板与组件
- 深底、细分割、紫/靛强调；大标题 + 短副文。
- Pricing：多列套餐卡；Login：居中 SSO。
"@ @(NotesFor 'linear-web')

Write-StyleGuide 'shopify-admin' 'Shopify Admin' @"
### 一句话定位
**电商后台登录壳**；深页需店铺会话，本批仅登录墙。

### 组件
- 居中登录卡、Shopify 绿强调、邮箱/SSO。
"@ @(NotesFor 'shopify-admin')

Write-StyleGuide 'github-web' 'GitHub' @"
### 一句话定位
**开发者协作门户**：首页仪表/探索 + Issues 列表 + 设置表单。

### 色板与组件
- 浅底、深字、绿主 CTA；顶栏搜索 + 仓库导航。
- Issues：过滤器 + 列表行；Settings：左导航 + 右表单。
"@ @(NotesFor 'github-web')

Write-StyleGuide 'slack-web' 'Slack' @"
### 一句话定位
**协作通信营销 + 登录入口**；工作区深页需登录则 SKIP。

### 组件
- 营销：彩色/插画英雄、产品卖点。
- Sign-in：工作区 URL / 邮箱入口。
"@ @(NotesFor 'slack-web')

Write-StyleGuide 'notion-web' 'Notion' @"
### 一句话定位
**文档协作工作区或营销门面**；可达则截工作区/设置，否则营销/登录。

### 组件
- 侧栏页面树 + 主编辑画布；设置为模态/侧栏。
"@ @(NotesFor 'notion-web')

Write-StyleGuide 'google-drive' 'Google Drive' @"
### 一句话定位
**文件网格/列表浏览器**；Material 风侧栏 + 主文件区。

### 组件
- 左导航（我的云端硬盘/共享/最近）；顶搜索；主区文件卡/行。
"@ @(NotesFor 'google-drive')

Write-StyleGuide 'figma-web' 'Figma' @"
### 一句话定位
**设计文件浏览器或营销首页**；登录后为网格文件库。

### 组件
- 文件网格、团队/草稿分区；营销为英雄 + CTA。
"@ @(NotesFor 'figma-web')

Write-StyleGuide 'apple-web' 'Apple' @"
### 一句话定位
**极简产品营销**：大留白、产品摄影英雄、细顶栏。

### 色板与组件
- 白/浅灰底、近黑字；全宽产品图；分区叙事滚动。
"@ @(NotesFor 'apple-web')

Write-StyleGuide 'tradingview-web' 'TradingView' @"
### 一句话定位
**高密度行情工作区**：图表主舞台 + 工具条 + 侧面板。

### 组件
- 顶工具条、K 线主区、左/右 Watchlist 等面板；深色专业终端感。
"@ @(NotesFor 'tradingview-web')

Write-StyleGuide 'aws-console' 'AWS Console' @"
### 一句话定位
**云控制台登录壳**；深页需账户，本批仅登录。

### 组件
- AWS 橙黑品牌、Root/IAM 选项、分区登录表单。
"@ @(NotesFor 'aws-console')

$log | Set-Content 'F:\project\design-library\_cap_log_classic.txt' -Encoding UTF8
$skips | Set-Content 'F:\project\design-library\_cap_skips_classic.txt' -Encoding UTF8
Write-Host '==== SKIPS ===='; $skips
Write-Host 'DONE-CLASSIC'

