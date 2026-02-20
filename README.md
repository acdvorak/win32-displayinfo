# DisplayInfo

Win32 CLI.

Shows a summary of connected/enabled displays.

## Windows version support

| Version          | Support              |
| :--------------- | :------------------- |
| Windows 7+       | ???                  |
| Windows 8.1+     | Basic                |
| Windows 10 1607+ | Standard             |
| Windows 11 24H2+ | HDR & advanced color |

## Feature detection

- Monitor/display device name(s)
- Resolution (width ✕ height)
- Refresh rate
- Bit depth per channel
- Physical connector type:
  - VGA
  - DVI
  - HDMI
  - DisplayPort
  - Internal
- Color support:
  - `advancedColorSupported`
  - `advancedColorActive`
  - `highDynamicRangeSupported`
  - `highDynamicRangeUserEnabled`
  - `wideColorSupported`
  - `wideColorUserEnabled`
  - RGB
  - YCbCr444
  - YCbCr422
  - YCbCr420
