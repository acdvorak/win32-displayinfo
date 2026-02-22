$BuildToolsExe = Join-Path $PSScriptRoot "vs_BuildTools.exe"
$VsConfigPath = Join-Path $PSScriptRoot ".vsconfig"

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
	$scriptPath = $MyInvocation.MyCommand.Path
	$elevated = Start-Process -FilePath "powershell.exe" -Verb RunAs -Wait -PassThru -ArgumentList @(
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", "`"$scriptPath`""
	)
	exit $elevated.ExitCode
}

if (-not (Test-Path $BuildToolsExe)) {
	Write-Host "Downloading VS 2022 Build Tools installer..."
	Invoke-WebRequest "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile $BuildToolsExe
}

$arguments = @(
	"--config", $VsConfigPath,
	"--quiet",
	"--wait",
	"--norestart",
	"--nocache"
)

Write-Host "Installing minimal VS 2022 Build Tools:"

try {
	$vsConfig = Get-Content -Path $VsConfigPath -Raw | ConvertFrom-Json
} catch {
	throw "Failed to parse .vsconfig at '$VsConfigPath': $($_.Exception.Message)"
}

$components = @($vsConfig.components | Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) })
foreach ($component in $components) {
	Write-Host "  - $component"
}

$addArguments = @()
foreach ($component in $components) {
	$addArguments += "--add"
	$addArguments += $component
}

Write-Host ""
Write-Host "This may take several minutes..."

$installArguments = @($arguments + $addArguments)
$process = Start-Process -FilePath $BuildToolsExe -ArgumentList $installArguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
	throw "vs_BuildTools.exe failed with exit code $($process.ExitCode)."
}

$vsDevCmdPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"
if (-not (Test-Path $vsDevCmdPath)) {
	throw "VsDevCmd.bat was not found at '$vsDevCmdPath'."
}

$validationCommand = "\"$vsDevCmdPath\" -arch=x64 && where cl && where link && where rc"
cmd /c $validationCommand
if ($LASTEXITCODE -ne 0) {
	throw "VC tools installed, but Windows SDK resource compiler (rc.exe) is unavailable. Ensure Windows 10 SDK is installed in VS Build Tools Installer."
}

Write-Host ""
Write-Host "Visual Studio Build Tools verification succeeded (cl/link/rc found)."
