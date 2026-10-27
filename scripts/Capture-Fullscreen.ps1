<#
.SYNOPSIS
  DPI-aware full-screen capture of the primary (or a named) monitor at PHYSICAL resolution,
  with an optional compressed AI copy (shot-ai.jpg).

.DESCRIPTION
  Windows display scaling (e.g. 150% on a 4K panel) makes a DPI-unaware process see the
  logical size (3840x2160 / 1.5 = 2560x1440). This script calls
  SetProcessDpiAwarenessContext(-4) = PER_MONITOR_AWARE_V2 BEFORE loading WinForms, so
  Screen.Bounds and CopyFromScreen operate in physical pixels. It also cross-checks against
  EnumDisplaySettings (always physical) and uses that if the two disagree.

.PARAMETER OutPath       Full-size PNG path (e.g. ...\apps\grok-bot\main\shot.png). Required.
.PARAMETER AiPath        Optional JPEG path for the AI copy. Use -Ai to default to <dir>\shot-ai.jpg.
.PARAMETER Ai            Switch: also write <OutDir>\shot-ai.jpg.
.PARAMETER Monitor       'primary' (default), a device name like '\\.\DISPLAY2', or a 0-based index.
.PARAMETER AiLongEdge    Long edge in px for the AI copy (default 1920).
.PARAMETER JpegQuality   JPEG quality 1-100 for the AI copy (default 82).
.PARAMETER MoveMouseAway Move the cursor to the top-right corner first (avoids taskbar hover previews).
.PARAMETER DelayMs       Wait before capture (default 300 ms).

.EXAMPLE
  .\Capture-Fullscreen.ps1 -OutPath F:\project\design-library\apps\grok-bot\main\shot.png -Ai -MoveMouseAway
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$OutPath,
  [string]$AiPath,
  [switch]$Ai,
  [string]$Monitor = 'primary',
  [int]$AiLongEdge = 1920,
  [ValidateRange(1, 100)][int]$JpegQuality = 82,
  [switch]$MoveMouseAway,
  [int]$DelayMs = 300
)

$ErrorActionPreference = 'Stop'

# --- 1. DPI awareness: must happen before System.Windows.Forms / System.Drawing touch the screen ---
if (-not ('DlNative.Dpi' -as [type])) {
  Add-Type -Namespace DlNative -Name Dpi -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr value);
[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
[DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
'@
}
$dpiOk = $false
try { $dpiOk = [DlNative.Dpi]::SetProcessDpiAwarenessContext([IntPtr](-4)) } catch {}
if (-not $dpiOk) {
  # Either already set for this process (fine if it was set to aware) or older Windows.
  try { [void][DlNative.Dpi]::SetProcessDPIAware() } catch {}
}

if (-not ('DlNative.DisplaySettings' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace DlNative {
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  public struct DEVMODE {
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
    public short dmSpecVersion; public short dmDriverVersion; public short dmSize; public short dmDriverExtra;
    public int dmFields; public int dmPositionX; public int dmPositionY; public int dmDisplayOrientation; public int dmDisplayFixedOutput;
    public short dmColor; public short dmDuplex; public short dmYResolution; public short dmTTOption; public short dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
    public short dmLogPixels; public int dmBitsPerPel; public int dmPelsWidth; public int dmPelsHeight;
    public int dmDisplayFlags; public int dmDisplayFrequency;
    public int dmICMMethod; public int dmICMIntent; public int dmMediaType; public int dmDitherType;
    public int dmReserved1; public int dmReserved2; public int dmPanningWidth; public int dmPanningHeight;
  }
  public static class DisplaySettings {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
    public static int[] Get(string device) {
      DEVMODE dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
      if (!EnumDisplaySettings(device, -1, ref dm)) return null;   // ENUM_CURRENT_SETTINGS
      return new int[] { dm.dmPositionX, dm.dmPositionY, dm.dmPelsWidth, dm.dmPelsHeight };
    }
  }
}
'@
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- 2. Pick the monitor ---
$screens = [System.Windows.Forms.Screen]::AllScreens
$screen = $null
if ($Monitor -eq 'primary') {
  $screen = [System.Windows.Forms.Screen]::PrimaryScreen
} elseif ($Monitor -match '^\d+$') {
  $screen = $screens[[int]$Monitor]
} else {
  $screen = $screens | Where-Object { $_.DeviceName -eq $Monitor } | Select-Object -First 1
}
if (-not $screen) {
  throw "Monitor '$Monitor' not found. Available: " + (($screens | ForEach-Object { "$($_.DeviceName) $($_.Bounds)" }) -join '; ')
}

$b = $screen.Bounds
$x = $b.X; $y = $b.Y; $w = $b.Width; $h = $b.Height
$phys = [DlNative.DisplaySettings]::Get($screen.DeviceName)
if ($phys -and ($phys[2] -ne $w -or $phys[3] -ne $h)) {
  Write-Warning ("Screen.Bounds {0}x{1} != physical {2}x{3} (process not DPI-aware?). Using physical size." -f $w, $h, $phys[2], $phys[3])
  $x = $phys[0]; $y = $phys[1]; $w = $phys[2]; $h = $phys[3]
}

# --- 3. Capture ---
if ($MoveMouseAway) { [void][DlNative.Dpi]::SetCursorPos($x + $w - 2, $y + 2) }
if ($DelayMs -gt 0) { Start-Sleep -Milliseconds $DelayMs }

$outDir = Split-Path -Parent $OutPath
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

$bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
try {
  $g.CopyFromScreen($x, $y, 0, 0, (New-Object System.Drawing.Size($w, $h)), [System.Drawing.CopyPixelOperation]::SourceCopy)
  $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)

  # --- 4. AI copy ---
  if ($Ai -and -not $AiPath) { $AiPath = Join-Path $outDir 'shot-ai.jpg' }
  $aiW = $null; $aiH = $null
  if ($AiPath) {
    $scale = [Math]::Min(1.0, $AiLongEdge / [double][Math]::Max($w, $h))
    $aiW = [int][Math]::Round($w * $scale); $aiH = [int][Math]::Round($h * $scale)
    $small = New-Object System.Drawing.Bitmap($aiW, $aiH)
    $g2 = [System.Drawing.Graphics]::FromImage($small)
    try {
      $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
      $g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
      $g2.DrawImage($bmp, 0, 0, $aiW, $aiH)
      $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
      $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
      $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$JpegQuality)
      $small.Save($AiPath, $codec, $ep)
    } finally { $g2.Dispose(); $small.Dispose() }
  }
} finally { $g.Dispose(); $bmp.Dispose() }

[pscustomobject]@{
  monitor   = $screen.DeviceName
  primary   = $screen.Primary
  full_path = (Resolve-Path $OutPath).Path
  full_px   = "${w}x${h}"
  full_bytes = (Get-Item $OutPath).Length
  ai_path   = $(if ($AiPath) { (Resolve-Path $AiPath).Path } else { $null })
  ai_px     = $(if ($AiPath) { "${aiW}x${aiH}" } else { $null })
  ai_bytes  = $(if ($AiPath) { (Get-Item $AiPath).Length } else { $null })
  dpi_context_set = $dpiOk
  captured_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
}
