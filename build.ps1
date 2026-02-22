$ErrorActionPreference = "Stop"

$Configuration = "Debug"
$VsWherePath = Join-Path ${env:ProgramFiles(x86)} `
	"Microsoft Visual Studio/Installer/vswhere.exe"

if (-not (Test-Path $VsWherePath)) {
	throw "vswhere.exe was not found at: $VsWherePath"
}

$VsInstallationPath = & $VsWherePath -latest -products * `
	-requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
	-property installationPath

if (-not $VsInstallationPath) {
	throw (
		"No Visual Studio Build Tools instance with VC tools was found. " +
		"Re-run deps.ps1 and ensure C++ Build Tools are installed."
	)
}

$VsInstallationPath = $VsInstallationPath.Trim()
$PresetBuilds = @(
	@{ ConfigurePreset = "Win32"; BuildPreset = "Win32-Debug"; OutputArch = "x86" },
	@{ ConfigurePreset = "x64"; BuildPreset = "x64-Debug"; OutputArch = "x64" }
)

$BinDir = Join-Path $PSScriptRoot "bin"
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null

foreach ($PresetBuild in $PresetBuilds) {
	$BuildDir = Join-Path $PSScriptRoot "out/$($PresetBuild.ConfigurePreset)"
	$CMakeCachePath = Join-Path $BuildDir "CMakeCache.txt"
	$CMakeFilesDir = Join-Path $BuildDir "CMakeFiles"

	if (Test-Path $CMakeCachePath) {
		Remove-Item $CMakeCachePath -Force
	}
	if (Test-Path $CMakeFilesDir) {
		Remove-Item $CMakeFilesDir -Recurse -Force
	}

	cmake --preset $PresetBuild.ConfigurePreset `
		-DCMAKE_GENERATOR_INSTANCE="$VsInstallationPath"
	if ($LASTEXITCODE -ne 0) {
		throw "CMake configure failed for preset '$($PresetBuild.ConfigurePreset)' with exit code $LASTEXITCODE."
	}

	cmake --build --preset $PresetBuild.BuildPreset
	if ($LASTEXITCODE -ne 0) {
		throw "CMake build failed for preset '$($PresetBuild.BuildPreset)' with exit code $LASTEXITCODE."
	}

	$BuiltExePath = Join-Path $BuildDir "$Configuration/DisplayInfo.exe"
	$DestExePath  = Join-Path $BinDir   "DisplayInfo-$($PresetBuild.OutputArch).exe"
	$BuiltPdbPath = Join-Path $BuildDir "$Configuration/DisplayInfo.pdb"
	$DestPdbPath  = Join-Path $BinDir   "DisplayInfo-$($PresetBuild.OutputArch).pdb"

	if (-not (Test-Path $BuiltExePath)) {
		throw "Expected build output not found: $BuiltExePath"
	}

	if (-not (Test-Path $BuiltPdbPath)) {
		throw "Expected build output not found: $BuiltPdbPath"
	}

	Copy-Item -Path $BuiltExePath -Destination $DestExePath -Force
	Copy-Item -Path $BuiltPdbPath -Destination $DestPdbPath -Force
}
