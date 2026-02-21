$ErrorActionPreference = "Stop"

$Configuration = "Debug"
$Platforms = @("Win32", "x64")

foreach ($Platform in $Platforms) {
	$BuildDir = Join-Path $PSScriptRoot "build/$Platform"

	cmake -S $PSScriptRoot -B $BuildDir -A $Platform
	cmake --build $BuildDir --config $Configuration
}
