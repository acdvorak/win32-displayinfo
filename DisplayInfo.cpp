#include "DisplayConfig/DisplayConfig.h"

#include <shellscalingapi.h>
#include <nlohmann/json.hpp>

#include <iostream>
#include <map>
#include <cmath>
#include <string_view>

#include <dxgi.h>
#include <dxgi1_6.h>

#include <wrl/client.h>
using Microsoft::WRL::ComPtr;
using nlohmann::json;

std::map<std::wstring, std::pair<long, DXGI_COLOR_SPACE_TYPE>> monitors;

static std::string WideToUtf8(const wchar_t* value)
{
	if (!value || !*value) {
		return {};
	}

	const int required = WideCharToMultiByte(CP_UTF8, 0, value, -1, nullptr, 0, nullptr, nullptr);
	if (required <= 1) {
		return {};
	}

	std::string utf8(static_cast<size_t>(required), '\0');
	WideCharToMultiByte(CP_UTF8, 0, value, -1, utf8.data(), required, nullptr, nullptr);
	utf8.resize(static_cast<size_t>(required - 1));
	return utf8;
}

static json Utf8OrNull(const wchar_t* value)
{
	if (!value || !*value) {
		return nullptr;
	}
	return WideToUtf8(value);
}

static BOOL CALLBACK EnumProc(HMONITOR hMonitor, HDC, LPRECT, LPARAM)
{
	MONITORINFOEXW monitorInfoEx = { sizeof(monitorInfoEx) };
	GetMonitorInfoW(hMonitor, &monitorInfoEx);

	UINT dpiX, dpiY;
	if (S_OK == GetDpiForMonitor(hMonitor, MDT_EFFECTIVE_DPI, &dpiX, &dpiY)) {
		monitors.try_emplace(monitorInfoEx.szDevice, std::lround(dpiY * 100. / 96.), DXGI_COLOR_SPACE_RESERVED);
	}

	return TRUE;
}

static std::wstring ColorSpaceToStr(DXGI_COLOR_SPACE_TYPE ColorSpace)
{
	std::wstring str;
#define UNPACK_VALUE(VALUE) case VALUE: str = L"" #VALUE; break;
	switch (ColorSpace) {
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P601);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020 );
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G2084_LEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_STUDIO_G2084_NONE_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_TOPLEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G2084_TOPLEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_GHLG_TOPLEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_FULL_GHLG_TOPLEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_STUDIO_G24_NONE_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_RGB_STUDIO_G24_NONE_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G24_LEFT_P709);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G24_LEFT_P2020);
		UNPACK_VALUE(DXGI_COLOR_SPACE_YCBCR_STUDIO_G24_TOPLEFT_P2020);
		default:
			str = std::to_wstring(static_cast<int>(ColorSpace));
	};
#undef UNPACK_VALUE

	return str;
}

static std::wstring ColorModeToStr(DISPLAYCONFIG_ADVANCED_COLOR_MODE ColorMode)
{
	std::wstring str;
#define UNPACK_VALUE(VALUE) case VALUE: str = L"" #VALUE; break;
	switch (ColorMode) {
		UNPACK_VALUE(DISPLAYCONFIG_ADVANCED_COLOR_MODE_SDR);
		UNPACK_VALUE(DISPLAYCONFIG_ADVANCED_COLOR_MODE_WCG);
		UNPACK_VALUE(DISPLAYCONFIG_ADVANCED_COLOR_MODE_HDR);
		default:
			str = std::to_wstring(static_cast<int>(ColorMode));
	};
#undef UNPACK_VALUE

	return str;
}

static void PrintUsage()
{
	std::wcout << L"Usage: DisplayInfo [--json]\n"
			   << L"  --json    Output structured JSON (pretty-printed)\n";
}

static json DisplayConfigToJson(const DisplayConfig_t& config, long dpiScalePercent, DXGI_COLOR_SPACE_TYPE colorSpace)
{
	json item;
	item["displayName"] = Utf8OrNull(config.displayName);
	item["monitorName"] = Utf8OrNull(config.monitorName);
	item["summary"] = WideToUtf8(DisplayConfigToString(config).c_str());

	if (config.width && config.height) {
		item["resolution"] = {
			{"width", config.width},
			{"height", config.height},
		};
	} else {
		item["resolution"] = nullptr;
	}

	if (config.refreshRate.Denominator != 0 && config.refreshRate.Numerator != 0) {
		item["refreshRateHz"] = static_cast<double>(config.refreshRate.Numerator) / static_cast<double>(config.refreshRate.Denominator);
	} else {
		item["refreshRateHz"] = nullptr;
	}

	item["outputTechnology"] = {
		{"value", config.outputTechnology},
		{"name", OutputTechnologyToString(config.outputTechnology) ? WideToUtf8(OutputTechnologyToString(config.outputTechnology)) : std::string()},
	};

	item["scanLineOrdering"] = {
		{"value", config.scanLineOrdering},
		{"interlaced", config.scanLineOrdering >= DISPLAYCONFIG_SCANLINE_ORDERING_INTERLACED},
	};

	if (dpiScalePercent > 0) {
		item["dpiScalingPercent"] = dpiScalePercent;
	} else {
		item["dpiScalingPercent"] = nullptr;
	}

	if (colorSpace != DXGI_COLOR_SPACE_RESERVED) {
		item["dxgiColorSpace"] = {
			{"value", colorSpace},
			{"name", WideToUtf8(ColorSpaceToStr(colorSpace).c_str())},
		};
	} else {
		item["dxgiColorSpace"] = nullptr;
	}

	if (config.bitsPerChannel) {
		const wchar_t* colorEncoding = ColorEncodingToString(config.colorEncoding);
		item["color"] = {
			{"bitsPerChannel", config.bitsPerChannel},
			{"encoding", colorEncoding ? WideToUtf8(colorEncoding) : std::string()},
			{"hdrSupported", config.HDRSupported()},
			{"hdrEnabled", config.HDREnabled()},
		};

		if (SysVersion::IsWin11_24H2OrGreater()) {
			auto& colors = config.windows1124H2Colors;
			item["color"]["advancedColor"] = {
				{"advancedColorSupported", colors.advancedColorSupported},
				{"advancedColorActive", colors.advancedColorActive},
				{"advancedColorLimitedByPolicy", colors.advancedColorLimitedByPolicy},
				{"highDynamicRangeSupported", colors.highDynamicRangeSupported},
				{"highDynamicRangeUserEnabled", colors.highDynamicRangeUserEnabled},
				{"wideColorSupported", colors.wideColorSupported},
				{"wideColorUserEnabled", colors.wideColorUserEnabled},
				{"activeColorMode", WideToUtf8(ColorModeToStr(colors.activeColorMode).c_str())},
			};
		} else {
			auto& colors = config.advancedColor;
			item["color"]["advancedColor"] = {
				{"advancedColorSupported", colors.advancedColorSupported},
				{"advancedColorEnabled", colors.advancedColorEnabled},
				{"wideColorEnforced", colors.wideColorEnforced},
				{"advancedColorForceDisabled", colors.advancedColorForceDisabled},
			};
		}
	} else {
		item["color"] = nullptr;
	}

	return item;
}

int wmain(int argc, wchar_t* argv[])
{
	bool jsonOutput = false;

	for (int i = 1; i < argc; ++i) {
		std::wstring_view arg = argv[i];
		if (arg == L"--json") {
			jsonOutput = true;
		} else if (arg == L"-h" || arg == L"--help") {
			PrintUsage();
			return 0;
		} else {
			std::wcerr << L"Unknown option: " << arg << L"\n\n";
			PrintUsage();
			return 1;
		}
	}

	if (SysVersion::IsWin10_1607OrGreater()) {
		SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
		EnumDisplayMonitors(nullptr, nullptr, EnumProc, 0);
	} else if (SysVersion::IsWin81OrGreater()) {
		SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE);
		EnumDisplayMonitors(nullptr, nullptr, EnumProc, 0);
	}

	ComPtr<IDXGIFactory> pIDXGIFactory;
	if (SUCCEEDED(CreateDXGIFactory(__uuidof(IDXGIFactory), reinterpret_cast<void**>(pIDXGIFactory.GetAddressOf())))) {
		ComPtr<IDXGIAdapter> pIDXGIAdapter;
		for (UINT adapter = 0; pIDXGIFactory->EnumAdapters(adapter, pIDXGIAdapter.ReleaseAndGetAddressOf()) != DXGI_ERROR_NOT_FOUND; ++adapter) {
			ComPtr<IDXGIOutput> pIDXGIOutput;
			for (UINT output = 0; pIDXGIAdapter->EnumOutputs(output, pIDXGIOutput.ReleaseAndGetAddressOf()) != DXGI_ERROR_NOT_FOUND; ++output) {
				ComPtr<IDXGIOutput6> output6;
				if (SUCCEEDED(pIDXGIOutput.As(&output6))) {
					DXGI_OUTPUT_DESC1 desc;
					if (SUCCEEDED(output6->GetDesc1(&desc))) {
						if (auto it = monitors.find(desc.DeviceName); it != monitors.end()) {
							it->second.second = desc.ColorSpace;
						} else {
							monitors.try_emplace(desc.DeviceName, 0, desc.ColorSpace);
						}
					}
				}
			}
		}
	}

	std::vector<DisplayConfig_t> displayConfigs;
	if (GetDisplayConfigs(displayConfigs)) {
		json payload;
		if (jsonOutput) {
			payload["displays"] = json::array();
		}

		for (const auto& config : displayConfigs) {
			long dpiScalePercent = 0;
			DXGI_COLOR_SPACE_TYPE colorSpace = DXGI_COLOR_SPACE_RESERVED;
			if (auto it = monitors.find(config.displayName); it != monitors.end()) {
				dpiScalePercent = it->second.first;
				colorSpace = it->second.second;
			}

			if (jsonOutput) {
				payload["displays"].push_back(DisplayConfigToJson(config, dpiScalePercent, colorSpace));
				continue;
			}

			auto str = L"\r\nDisplay: " + DisplayConfigToString(config);
			if (colorSpace != DXGI_COLOR_SPACE_RESERVED) {
				str.append(std::format(L", Color Space: {}", ColorSpaceToStr(colorSpace)));
			}
			if (dpiScalePercent) {
				str.append(std::format(L"\n         DPI scaling factor: {}%", dpiScalePercent));
			}
			std::wcout << str << std::endl;
			if (config.bitsPerChannel) {
				const wchar_t* colenc = ColorEncodingToString(config.colorEncoding);
				if (colenc) {
					str = std::format(L"  Color: {} {}-bit", colenc, config.bitsPerChannel);
					if (config.HDRSupported()) {
						str.append(L", HDR10: ");
						str.append(config.HDREnabled() ? L"on" : L"off");

						if (SysVersion::IsWin11_24H2OrGreater()) {
							auto& colors = config.windows1124H2Colors;
							str.append(std::format(L"\r\n         Advanced Color: Supported: {}, Active: {}, Limited by OS policy: {}, HDR is supported: {}",
												   colors.advancedColorSupported, colors.advancedColorActive,
												   colors.advancedColorLimitedByPolicy, colors.highDynamicRangeSupported));
							str.append(std::format(L"\r\n                         HDR enabled: {}, Wide supported: {}, Wide enabled: {}",
												   colors.highDynamicRangeUserEnabled, colors.wideColorSupported,
												   colors.wideColorUserEnabled));
							str.append(std::format(L"\r\n                         Display color mode: {}", ColorModeToStr(colors.activeColorMode)));
						} else {
							auto& colors = config.advancedColor;
							str.append(std::format(L"\r\n         Advanced Color: Supported: {}, Enabled: {}, Wide forced: {}, Force disabled: {}",
												   colors.advancedColorSupported, colors.advancedColorEnabled,
												   colors.wideColorEnforced, colors.advancedColorForceDisabled));
						}
					}

					std::wcout << str << std::endl;
				}
			}
		}

		if (jsonOutput) {
			std::cout << payload.dump(2) << std::endl;
		}
	}

	return 0;
}
