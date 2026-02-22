$ErrorActionPreference = "Stop"

$Configuration = "Debug"
$Generator = "Visual Studio 17 2022"
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

	cmake -S $PSScriptRoot -B $BuildDir -G $Generator -A $Platform.CMakePlatform
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
