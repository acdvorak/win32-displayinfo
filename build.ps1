$ErrorActionPreference = "Stop"

$Configuration = "Debug"
$Generator = "Visual Studio 17 2022"
$VsWherePath = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio/Installer/vswhere.exe"

if (-not (Test-Path $VsWherePath)) {
	throw "vswhere.exe was not found at: $VsWherePath"
}

$VsInstallationPath = & $VsWherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $VsInstallationPath) {
	throw "No Visual Studio Build Tools instance with VC tools was found. Re-run deps.ps1 and ensure C++ Build Tools are installed."
}

$VsInstallationPath = $VsInstallationPath.Trim()
$Platforms = @(
	@{ CMakePlatform = "Win32"; OutputArch = "x86" },
	@{ CMakePlatform = "x64"; OutputArch = "x64" }
)

$BinDir = Join-Path $PSScriptRoot "bin"
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null

foreach ($Platform in $Platforms) {
	$BuildDir = Join-Path $PSScriptRoot "build/$($Platform.CMakePlatform)"
	$CMakeCachePath = Join-Path $BuildDir "CMakeCache.txt"
	$CMakeFilesDir = Join-Path $BuildDir "CMakeFiles"

	if (Test-Path $CMakeCachePath) {
		Remove-Item $CMakeCachePath -Force
	}

	if (Test-Path $CMakeFilesDir) {
		Remove-Item $CMakeFilesDir -Recurse -Force
	}

	cmake -S $PSScriptRoot -B $BuildDir -G $Generator -A $Platform.CMakePlatform -DCMAKE_GENERATOR_INSTANCE="$VsInstallationPath"
	cmake --build $BuildDir --config $Configuration

	$BuiltExePath = Join-Path $BuildDir "$Configuration/DisplayInfo.exe"
	$DestinationExePath = Join-Path $BinDir "DisplayInfo-$($Platform.OutputArch).exe"
	$BuiltPdbPath = Join-Path $BuildDir "$Configuration/DisplayInfo.pdb"
	$DestinationPdbPath = Join-Path $BinDir "DisplayInfo-$($Platform.OutputArch).pdb"

	if (-not (Test-Path $BuiltExePath)) {
		throw "Expected build output not found: $BuiltExePath"
	}

	if (-not (Test-Path $BuiltPdbPath)) {
		throw "Expected build output not found: $BuiltPdbPath"
	}

	Copy-Item -Path $BuiltExePath -Destination $DestinationExePath -Force
	Copy-Item -Path $BuiltPdbPath -Destination $DestinationPdbPath -Force
}
