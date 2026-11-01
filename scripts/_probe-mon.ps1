Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public class Mon {
  [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr v);
  [DllImport("user32.dll")] public static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr lprcClip, MonitorEnumProc lpfnEnum, IntPtr dwData);
  public delegate bool MonitorEnumProc(IntPtr hMonitor, IntPtr hdcMonitor, ref RECT lprcMonitor, IntPtr dwData);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left,Top,Right,Bottom; }
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool GetMonitorInfo(IntPtr hMonitor, ref MONITORINFOEX lpmi);
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct MONITORINFOEX {
    public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string szDevice;
  }
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct DEVMODE {
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
    public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
    public int dmFields, dmPositionX, dmPositionY, dmDisplayOrientation, dmDisplayFixedOutput;
    public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
    public short dmLogPixels; public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
    public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType, dmReserved1, dmReserved2, dmPanningWidth, dmPanningHeight;
  }
  public static void Run() {
    SetProcessDpiAwarenessContext((IntPtr)(-4));
    EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, (IntPtr h, IntPtr hdc, ref RECT r, IntPtr d) => {
      MONITORINFOEX mi = new MONITORINFOEX(); mi.cbSize = Marshal.SizeOf(typeof(MONITORINFOEX));
      GetMonitorInfo(h, ref mi);
      Console.WriteLine(string.Format("MON {0} flags={1} mon=({2},{3})-({4},{5}) {6}x{7}", mi.szDevice, mi.dwFlags, mi.rcMonitor.Left, mi.rcMonitor.Top, mi.rcMonitor.Right, mi.rcMonitor.Bottom, mi.rcMonitor.Right-mi.rcMonitor.Left, mi.rcMonitor.Bottom-mi.rcMonitor.Top));
      DEVMODE dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
      if (EnumDisplaySettings(mi.szDevice, -1, ref dm))
        Console.WriteLine(string.Format("  MODE {0}x{1} @{2}Hz pos=({3},{4})", dm.dmPelsWidth, dm.dmPelsHeight, dm.dmDisplayFrequency, dm.dmPositionX, dm.dmPositionY));
      return true;
    }, IntPtr.Zero);
    foreach (var dev in new string[]{"\\\\.\\DISPLAY1","\\\\.\\DISPLAY2","\\\\.\\DISPLAY3","\\\\.\\DISPLAY13","\\\\.\\DISPLAY14"}) {
      DEVMODE dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
      if (EnumDisplaySettings(dev, -1, ref dm))
        Console.WriteLine(string.Format("EDS {0} => {1}x{2} pos=({3},{4})", dev, dm.dmPelsWidth, dm.dmPelsHeight, dm.dmPositionX, dm.dmPositionY));
      else Console.WriteLine("EDS "+dev+" FAIL");
    }
  }
}
"@
[Mon]::Run()
