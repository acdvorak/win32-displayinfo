# DisplayInfo

Win32 CLI.

Shows a summary of connected/enabled displays.

## Usage

```ps1
DisplayInfo.exe

DisplayInfo.exe --json
```

# Example output

## Windows 10 PC

- HP Z420
- Windows 10 Pro `22H2` build `19045.6466`
- NVIDIA Quadro 600 GPU
- Two external monitors:
  - Samsung S95C (DisplayPort-to-HDMI adapter)
  - Dell ST2320L (DVI-D)

In-person physical displays (no RDP):

```
Display: QCQ95S [\\.\DISPLAY1] 1900x1058@60.000 HDMI, Color Space: DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709
         DPI scaling factor: 100%
  Color: RGB 8-bit

Display: DELL ST2320L [\\.\DISPLAY2] 1920x1080@60.000 DVI, Color Space: DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709
         DPI scaling factor: 175%
  Color: RGB 8-bit
```

```json
{
  "displays": [
    {
      "monitorName": "QCQ95S",
      "displayName": "\\\\.\\DISPLAY1",
      "summary": "QCQ95S [\\\\.\\DISPLAY1] 1900x1058@60.000 HDMI",
      "resolution": {
        "width": 1900,
        "height": 1058
      },
      "refreshRateHz": 60.0,
      "outputTechnology": {
        "value": 5,
        "name": "HDMI"
      },
      "scanLineOrdering": {
        "value": 1,
        "interlaced": false
      },
      "dpiScalingPercent": 100,
      "dxgiColorSpace": {
        "value": 0,
        "name": "DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709"
      },
      "color": {
        "bitsPerChannel": 8,
        "encoding": "RGB",
        "hdrSupported": false,
        "hdrEnabled": false,
        "advancedColor": {
          "advancedColorEnabled": false,
          "advancedColorForceDisabled": false,
          "advancedColorSupported": false,
          "wideColorEnforced": false
        }
      }
    },
    {
      "monitorName": "DELL ST2320L",
      "displayName": "\\\\.\\DISPLAY2",
      "summary": "DELL ST2320L [\\\\.\\DISPLAY2] 1920x1080@60.000 DVI",
      "resolution": {
        "width": 1920,
        "height": 1080
      },
      "refreshRateHz": 60.0,
      "outputTechnology": {
        "value": 4,
        "name": "DVI"
      },
      "scanLineOrdering": {
        "value": 1,
        "interlaced": false
      },
      "dpiScalingPercent": 175,
      "dxgiColorSpace": {
        "value": 0,
        "name": "DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709"
      },
      "color": {
        "bitsPerChannel": 8,
        "encoding": "RGB",
        "hdrSupported": false,
        "hdrEnabled": false,
        "advancedColor": {
          "advancedColorEnabled": false,
          "advancedColorForceDisabled": false,
          "advancedColorSupported": false,
          "wideColorEnforced": false
        }
      }
    }
  ]
}
```

Over Remote Desktop:

```
Display:  [\\.\DISPLAY97] 1608x965@32.000, Color Space: DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709
         DPI scaling factor: 100%
  Color: RGB 8-bit
```

```json
{
  "displays": [
    {
      "monitorName": null,
      "displayName": "\\\\.\\DISPLAY129",
      "summary": " [\\\\.\\DISPLAY129] 1608x965@32.000",
      "resolution": {
        "width": 1608,
        "height": 965
      },
      "refreshRateHz": 32.0,
      "outputTechnology": {
        "value": -1,
        "name": ""
      },
      "scanLineOrdering": {
        "value": 1,
        "interlaced": false
      },
      "dpiScalingPercent": 100,
      "dxgiColorSpace": {
        "value": 0,
        "name": "DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709"
      },
      "color": {
        "bitsPerChannel": 8,
        "encoding": "RGB",
        "hdrEnabled": false,
        "hdrSupported": false,
        "advancedColor": {
          "advancedColorEnabled": false,
          "advancedColorForceDisabled": false,
          "advancedColorSupported": false,
          "wideColorEnforced": false
        }
      }
    }
  ]
}
```

## Windows 7 Virtual Machine

- Windows 7 Pro SP1
- VMWare Workstation 16 Pro
  - Version `16.2.5` build `20904516`

```
Display:  [\\.\DISPLAY1] 1606x813@60.000 VGA
```

```json
{
  "displays": [
    {
      "monitorName": null,
      "displayName": "\\\\.\\DISPLAY1",
      "summary": " [\\\\.\\DISPLAY1] 1606x813@60.000 VGA",
      "resolution": {
        "width": 1606,
        "height": 813
      },
      "refreshRateHz": 60.0,
      "outputTechnology": {
        "value": 0,
        "name": "VGA"
      },
      "scanLineOrdering": {
        "value": 1,
        "interlaced": false
      },
      "dpiScalingPercent": null,
      "dxgiColorSpace": null,
      "color": null
    }
  ]
}
```

# Feature detection

- Monitor/display device name(s)
- Resolution (`W` × `H`)
- Refresh rate (Hz)
- Bit depth per channel (8, 10, 12, 14, 16)
- DPI scaling (100%, 125%, 150%, etc.)
- Physical connector type (⚠️ not always accurate on old PCs/GPUs)
  - VGA
  - DVI
  - HDMI
  - DisplayPort
  - Internal
- Color support:
  - HDR10 supported and active (enabled/disabled)
  - Advanced color supported and active (enabled/disabled)
  - Wide color supported and active (enabled/disabled)
  - RGB, YCbCr444, YCbCr422, YCbCr420

# Windows version support

- Windows 7+:
  - Monitor/display names
  - Resolution
  - Refresh rate
  - Physical connector type (HDMI/DVI/VGA/etc.)

- Windows 8.1+:
  - Per-monitor DPI scaling (100%, 125%, 150%, etc.)

- Windows 10 1607+:
  - Per-thread DPI scaling (100%, 125%, 150%, etc.)
  - HDR10 supported and enabled/disabled
  - Advanced color supported and enabled/disabled

- Windows 11 24H2+:
  - Wide color supported and enabled/disabled
  - Active color mode (SDR/WCG/HDR)

# Building

### Prerequisites

[VS 2022 Build Tools (LTSC)](https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history#fixed-version-bootstrappers)

Use [`.vsconfig`](./.vsconfig) to select the minimum necessary dependencies:

- MSVC v143 - VS 2022 C++ x64/86 build tools
- C++ CMake tools for Windows
- Windows 10 SDK

### Vendored dependencies

- `nlohmann/json` `v3.11.3` is vendored as a single header:
  - `third_party/nlohmann/json.hpp`
  - License: `third_party/nlohmann/LICENSE.MIT`

# API documentation

## Windows Hardware Design

[Display Component Guidelines](https://learn.microsoft.com/en-us/windows-hardware/design/component-guidelines/display)

> ### Dynamic refresh rate switching for media content
>
> On supported hardware, Windows 10 automatically and seamlessly switches the
> refresh rate to better match the frame rate of any full-screen videos that are
> playing. For example, when playing a 24fps video (film), Windows 10 switches
> to 24 Hz or 48 Hz. When playing a 30fps video (NTSC TV), Windows 10 switches
> to 30 Hz.
>
> ### Adaptive sync for gaming
>
> On supported hardware, Windows 10 (version 1903 and later) supports
> automatically synchronizing the refresh rate to the presentation rate of games
> running fullscreen.
>
> ### High dynamic range (HDR) and wide color gamut (WCG)
>
> On supported hardware, Windows 10 supports high dynamic range (HDR) displays
> which may optionally have a color gamut wider than sRGB. This is referred to
> as Windows Advanced Color. When Advanced Color is active on a display, Windows
> 10 will automatically manage the colors for all applications in order to
> ensure color accuracy and consistency.
>
> ### Display descriptors
>
> The Windows display stack relies on accurate information reported in a
> display's hardware descriptor. Windows supports VESA Extended Display
> Identifier (EDID) descriptors, as well as limited support for DisplayID
> descriptors.
>
> For all descriptors, Windows depends on the following pieces of information
> (read directly from the descriptor):
>
> | Descriptor feature                                      | Requirement                       | Notes                                                                                    |
> | :------------------------------------------------------ | :-------------------------------- | :--------------------------------------------------------------------------------------- |
> | Physical size                                           | Required                          | Used for DPI scaling calculations. Projectors may set the physical size to zero.         |
> | Native resolution                                       | Required                          | Used for DPI scaling calculations and selecting the default mode                         |
> | Unique serial number per device                         | Required                          | Used to track user preferences for individual displays                                   |
> | Unique model name                                       | Required                          | Used to identify models for providing friendly names, monitor drivers, and OEM overrides |
> | Colorimetry data (e.g. white point and color primaries) | Required for HDR and WCG displays | Tolerance is expected to have ∆E < 5                                                     |
> | Luminance and HDR static tone mapping data              | Required for HDR and WCG displays |                                                                                          |
>
> Windows specifically supports the following display descriptor formats for the
> above features:
>
> | Descriptor format                          | Windows 10 support     | Windows 11 support     | Requirement                                                                                     |
> | :----------------------------------------- | :--------------------- | :--------------------- | :---------------------------------------------------------------------------------------------- |
> | EDID 1.4 base block                        | Supported              | Supported              | Required for displays with an EDID                                                              |
> | CEA-861 extension blocks                   | Supported              | Supported              |                                                                                                 |
> | CTA-861.3-A HDR static metadata extension  | Supported              | Supported              | Required for HDR displays with an EDID on Windows 10, see below for HDR descriptor requirements |
> | DisplayID 1.3 (as an EDID extension block) | Not supported, ignored | Not supported, ignored | Graphics drivers may support extended timing information                                        |
> | DisplayID 2.0 (in standalone block)        | Supported              | Supported              | See below for DisplayID 2.0 requirements                                                        |
> | DisplayID 2.0 (as an EDID extension block) | Not supported, ignored | Supported              | See below for DisplayID 2.0 requirements                                                        |
>
> ### HDR display descriptor requirements
>
> Windows 10 does not support DisplayID 2.0 as an EDID extension block, so HDR
> displays should use an EDID with a CTA-861.3-A HDR static metadata extension,
> or a standalone DisplayID 2.0 block without an EDID.
>
> Windows 11 adds support for DisplayID 2.0 as an EDID extension block, but
> requires that HDR properties be specified using a DisplayID 2.0 Display
> Parameters block for colorimetry and a DisplayID 2.0 Display Features block
> for EOTF support. Windows 11 does not support HDR parameters to be specified
> in a CTA-861.3-A embedded in a DisplayID sub-block.
>
> ### DisplayID 2.0 requirements
>
> Windows does not support DisplayID 1.x blocks, and always ignores them.
>
> Windows 10 has limited support for standalone DisplayID 2.0 descriptors. These
> descriptors are only utilized if the monitor has no EDID.
>
> Windows 11 adds support for qualifying DisplayID 2.0 descriptors embedded in
> EDID extension blocks. Windows 11 also now prefers qualifying DisplayID 2.0
> descriptors over EDID for all properties other than the PnP identification. In
> other words, in the presence of a qualifying DisplayID 2.0 descriptor, legacy
> EDID blocks are assumed to be deprecated legacy blocks maintained only for
> older systems. Therefore, it's important that a DisplayID 2.0 descriptor fully
> encompass all properties to identify and describe a monitor.
>
> The DisplayID 2.1 specification adds clarifications around requirements for
> DisplayID descriptors, both embedded in an EDID extension and standalone.
> Windows 11 requires that DisplayID 2.0 descriptors follow these requirements
> precisely in order for the descriptor to be considered a "qualifying"
> DisplayID 2.0 descriptor. If Windows finds that the DisplayID block does not
> meet these requirements, the block is entirely ignored and the system falls
> back to only using the EDID. In particular:
>
> - The DisplayID container must have version 2.0 or later.
> - The first sub-block must be a valid Product Identification sub-block.
> - There must be at least one Type VII timing sub-block as the first mode block
>   declaring the native mode.
> - There must be a valid Display Parameters sub-block.
>
> Windows 11 prefers descriptors in the following order:
>
> - Standalone DisplayID 2.0 descriptor (if qualifying)
> - DisplayID 2.0 descriptor embedded in EDID extension blocks (if qualifying)
> - EDID
>
> ### Connectivity standards
>
> #### DisplayPort and Embedded DisplayPort (eDP)
>
> On supported hardware, Windows 10 and Windows 11 support displays connected
> via the DisplayPort standard, including daisy-chaining and multi-stream
> topology (MST) configurations with multiple monitors attached to a hub device.
>
> #### Miracast
>
> On supported hardware, Windows 10 and Windows 11 support wireless projection
> over Miracast.

## Windows Runtime API

- [`Windows.Devices.Display` Namespace](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display?view=winrt-26100)
  - EDID and DisplayID information
  - Windows 10, version 1803+ (introduced in 10.0.17134.0)
  - [`DisplayMonitor` Class](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display.displaymonitor?view=winrt-26100)
  - [`DisplayMonitorConnectionKind` Enum](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display.displaymonitorconnectionkind?view=winrt-26100)
  - [`DisplayMonitorDescriptorKind` Enum](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display.displaymonitordescriptorkind?view=winrt-26100)
  - [`DisplayMonitorPhysicalConnectorKind` Enum](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display.displaymonitorphysicalconnectorkind?view=winrt-26100)
  - [`DisplayMonitorUsageKind` Enum](https://learn.microsoft.com/en-us/uwp/api/windows.devices.display.displaymonitorusagekind?view=winrt-26100)

## Win32 APIs

Headers:

```cpp
#include <D3d9types.h>
#include <dxgi.h>
#include <dxgi1_3.h>
#include <dxgi1_6.h>
#include <shellscalingapi.h>
#include <Windows.h>
#include <wingdi.h>
#include <winuser.h>
#include <wrl/client.h>
```

`winuser.h`:

- [`EnumDisplayMonitors` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaymonitors)
  - Enumerates display monitors (including invisible pseudo-monitors associated
    with the mirroring drivers) that intersect a region formed by the
    intersection of a specified clipping rectangle and the visible region of a
    device context.
  - Windows 2000+
- [`GetMonitorInfoW` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmonitorinfow)
  - Retrieves information about a display monitor.
  - Windows 2000+
- [`MONITORINFOEXW` structure](https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-monitorinfoexw)
  - Contains information about a display monitor.
  - Windows 2000+
- [`GetSystemMetrics` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics)
  - `SM_CMONITORS`: The number of display monitors on a desktop.
  - Windows 2000+
- [`DisplayConfigGetDeviceInfo` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-displayconfiggetdeviceinfo)
  - Retrieves display configuration information.
  - Windows Vista+
- [`QueryDisplayConfig` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-querydisplayconfig)
  - Retrieves information about all possible display paths for all display
    devices, or views, in the current setting.
  - Windows 7+
- [`SetThreadDpiAwarenessContext` function](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext)
  - Sets the DPI awareness for the current thread to the provided value.
  - Windows 10, version 1607+

`wingdi.h`:

- [`DISPLAYCONFIG_MODE_INFO` structure](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-displayconfig_mode_info)
  - Windows 7+
- [`DISPLAYCONFIG_DEVICE_INFO_TYPE` enumeration](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ne-wingdi-displayconfig_device_info_type)
  - Windows 7+

`dxgi.h`:

- [`CreateDXGIFactory` function](https://learn.microsoft.com/en-us/windows/win32/api/dxgi/nf-dxgi-createdxgifactory)
  - Creates a DXGI 1.0 factory that you can use to generate other DXGI objects.
  - Note: Do not mix the use of DXGI 1.0 (`IDXGIFactory`) and DXGI 1.1
    (`IDXGIFactory1`) in an application. Use `IDXGIFactory` or `IDXGIFactory1`,
    but not both in an application.
  - Windows 7+
- [`IDXGIFactory::EnumAdapters` method](https://learn.microsoft.com/en-us/windows/win32/api/dxgi/nf-dxgi-idxgifactory-enumadapters)
  - Enumerates both adapters (video cards) with or without outputs.
  - Windows 7+
- [`CreateDXGIFactory1` function](https://learn.microsoft.com/en-us/windows/win32/api/dxgi/nf-dxgi-createdxgifactory1)
  - Creates a DXGI 1.1 factory that you can use to generate other DXGI objects.
  - Note: Do not mix the use of DXGI 1.0 (`IDXGIFactory`) and DXGI 1.1
    (`IDXGIFactory1`) in an application. Use `IDXGIFactory` or `IDXGIFactory1`,
    but not both in an application.
  - Windows 7+
- [`IDXGIFactory1::EnumAdapters1` method](https://learn.microsoft.com/en-us/windows/win32/api/dxgi/nf-dxgi-idxgifactory1-enumadapters1)
  - Enumerates both adapters (video cards) with or without outputs.
  - Windows 7+

`dxgi1_3.h`:

- [`CreateDXGIFactory2` function](https://learn.microsoft.com/en-us/windows/win32/api/dxgi1_3/nf-dxgi1_3-createdxgifactory2)
  - Creates a DXGI 1.3 factory that you can use to generate other DXGI objects.
  - Windows 8.1+

`shellscalingapi.h`:

- [`GetDpiForMonitor` function](https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor)
  - Windows 8.1+
- [`SetProcessDpiAwareness` function](https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-setprocessdpiawareness)
  - Windows 8.1+
