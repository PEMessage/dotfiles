# Thanks to :https://github.com/BoatStuck/SDRBrightness/tree/main
# Thanks to :https://www.reddit.com/r/Windows10/comments/16blmdz/direct_hdr_brightness_shortcut/

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public struct Rect
{
    public int left;
    public int top;
    public int right;
    public int bottom;
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 4)]
public class MonitorInfo
{
    public int cbSize = Marshal.SizeOf(typeof(MonitorInfo));
    public Rect rcMonitor = new Rect();
    public Rect rcWork = new Rect();
    public int dwFlags = 0;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
    public char[] szDevice = new char[32];
}

public class DisplayInfo
{
    public string Availability { get; set; }
    public string ScreenHeight { get; set; }
    public string ScreenWidth { get; set; }
    public Rect MonitorArea { get; set; }
    public Rect WorkArea { get; set; }
    public IntPtr MonitorHandle { get; set; }
}

public class ScreenBrightnessSetter
{
    [DllImport("kernel32", CharSet = CharSet.Unicode)]
    public static extern IntPtr LoadLibrary(string lpFileName);
    
    [DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, int address);
    
    [DllImport("user32.dll")]
    public static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr lprcClip, EnumMonitorsDelegate lpfnEnum, IntPtr dwData);
    
    [DllImport("User32.dll", CharSet = CharSet.Auto)]
    public static extern bool GetMonitorInfo(IntPtr hmonitor, [In, Out] MonitorInfo info);
    
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    public delegate void DwmpSDRToHDRBoostPtr(IntPtr monitor, double brightness);

    public delegate bool EnumMonitorsDelegate(IntPtr hMonitor, IntPtr hdcMonitor, ref Rect lprcMonitor, IntPtr dwData);

    public static DisplayInfo[] GetDisplays()
    {
        System.Collections.Generic.List<DisplayInfo> col = new System.Collections.Generic.List<DisplayInfo>();

        EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero,
            delegate (IntPtr hMonitor, IntPtr hdcMonitor, ref Rect lprcMonitor, IntPtr dwData)
            {
                MonitorInfo mi = new MonitorInfo();
                mi.cbSize = Marshal.SizeOf(mi);
                bool success = GetMonitorInfo(hMonitor, mi);
                if (success)
                {
                    DisplayInfo di = new DisplayInfo();
                    di.ScreenWidth = (mi.rcMonitor.right - mi.rcMonitor.left).ToString();
                    di.ScreenHeight = (mi.rcMonitor.bottom - mi.rcMonitor.top).ToString();
                    di.MonitorArea = mi.rcMonitor;
                    di.WorkArea = mi.rcWork;
                    di.Availability = mi.dwFlags.ToString();
                    di.MonitorHandle = hMonitor;
                    col.Add(di);
                }
                return true;
            }, IntPtr.Zero);
        return col.ToArray();
    }
}
"@

function Set-ScreenBrightness {
    param(
        [double]$Brightness
    )

    $minBrightness = 1.0
    $maxBrightness = 6.0

    if ($Brightness -lt $minBrightness) {
        $Brightness = $minBrightness
    }
    elseif ($Brightness -gt $maxBrightness) {
        $Brightness = $maxBrightness
    }

    Write-Host "Setting brightness to $Brightness"

    $hmodule_dwmapi = [ScreenBrightnessSetter]::LoadLibrary("dwmapi.dll")
    $changeBrightness = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
        [ScreenBrightnessSetter]::GetProcAddress($hmodule_dwmapi, 171),
        [ScreenBrightnessSetter+DwmpSDRToHDRBoostPtr]
    )

    $monitors = [ScreenBrightnessSetter]::GetDisplays()
    foreach ($monitor in $monitors) {
        Write-Host "Changing brightness for monitor handle: $($monitor.MonitorHandle) to: $Brightness"
        $changeBrightness.Invoke($monitor.MonitorHandle, $Brightness)
    }
}

# Main execution
if ($args.Count -gt 0) {
    $brightness = 0
    if ([double]::TryParse($args[0], [ref]$brightness)) {
        Set-ScreenBrightness -Brightness $brightness
    }
    else {
        Write-Host "Cannot parse input, exiting: $($args[0])"
        exit 1
    }
}
else {
    $input = Read-Host "Enter desired brightness from 1.0 to 6.0"
    $brightness = 0
    if ([double]::TryParse($input, [ref]$brightness)) {
        Set-ScreenBrightness -Brightness $brightness
    }
    else {
        Write-Host "Cannot parse input, exiting"
        exit 1
    }
}