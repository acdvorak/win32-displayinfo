# DisplayInfo

Win32 CLI.

Shows a summary of connected/enabled displays.

## Usage

```ps1
DisplayInfo.exe

DisplayInfo.exe --json
```

## Example output

### Windows 10 PC

- HP Z420
- Windows 10 Pro `22H2` build `19045.6466`
- NVIDIA Quadro 600 GPU
- Two external monitors:
  - Samsung S95C (DisplayPort-to-HDMI adapter)
  - Dell ST2320L (DVI-D)

In-person physical displays (no RDP):

```
Display: QCQ95S [\\.\DISPLAY1] 1900x1058@60.000 DVI, Color Space: DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709
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
      "displayName": "\\\\.\\DISPLAY1",
      "monitorName": "DELL ST2320L",
      "summary": "DELL ST2320L [\\\\.\\DISPLAY1] 1920x1080@60.000 HDMI",
      "resolution": {
        "width": 1920,
        "height": 1080
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
      "dpiScalingPercent": 125,
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
          "advancedColorSupported": false,
          "advancedColorEnabled": false,
          "wideColorEnforced": false,
          "advancedColorForceDisabled": false
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

### Windows 7 Virtual Machine

- Windows 7 Pro SP1
- VMWare Workstation 16 Pro
  - Version `16.2.5` build `20904516`

```
Display:  [\\.\DISPLAY1] 1606x813@60.000 VGA
```

## Feature detection

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

## Windows version support

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

## Building

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
